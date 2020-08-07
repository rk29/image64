#include <stdio.h>
#include <ctype.h>
#include <malloc.h>
#include <string.h>
#include <assert.h>

#define N_LOGICAL_UNITS 11
int logical_unit_offsets[] = { 
-1000, // 0
-1000, // 1
-1000, // 2
-1000, // 3
-952, // 4
5848, // 5
9928, // 6
9999999, // 7
9999999, // 8
9999999, // 9
9999999, // 10
9999999 // end
};

#define HEXDUMP_BYTES_PER_LINE 16

#define BLOCKSIZE 512
#define FILENAME_SIZE 16

// 0x10 number of blocks in file (including header)
#define FILESIZE_OFFSET 0x10

// 0x12 number of records per block or load address for program files

// 0x14 number of bytes per record
// 0x16 number of records in file

// 0x18 file type
#define FILETYPE_OFFSET 0x18

// 0x19 number of blocsk per cylinder (bitmap only)
// 0x19 hi order bit of number of bytes in last block (MSB, bit 0 only)
#define LASTBLOCK_MSB_OFFSET 0x19

// 0x1a load address of this file
#define LOADADDR_OFFSET 0x1a

// 0x1c number of bytes in last block (LSB)
#define LASTBLOCK_LSB_OFFSET 0x1c

// 0x1d user/logical unit
#define USER_LU_OFFSET 0x1d

// 0x1e header block active (0xac or 0xaf means active header)
#define HEADER_ACTIVE_OFFSET 0x1e

// 0x20 block list (middle and low order bytes)
#define BLOCKLIST_OFFSET 0x20

// file types

// contiguous dos system file
#define SYS_FILE 0x01
// contiguous dos processor file
#define PROC_FILE 0x02
// special dos processor, runs outsize dosovl area
#define SPEC_FILE 0x03
// multiple directory index file
#define IND_FILE 0x04
// contiguous data file
#define CONT_FILE 0x05

// basic language program file
#define PRG_FILE 0x0B
// ML program file
#define ML_FILE 0x0C
// sequential file
#define SEQ_FILE 0x0D
// user file
#define USER_FILE 0x0E
// relative file
#define REL_FILE 0x0F
// random file
#define RND_FILE 0x10

struct lk_dir_entry
{
    int logical_unit;
    int user;
    unsigned char *filename;
    int type;
    int load_address;
    int bytes_in_last_block;
    int n_blocks;
    int *block_list;
};

struct entry_list
{
    struct lk_dir_entry *entry;
    struct entry_list *next;
};

int find_logical_unit(int blocknum)
{
    for (int i=0; i<N_LOGICAL_UNITS; i++)
    {
        if (blocknum < logical_unit_offsets[i+1])
        {
            return i;
        }
   }
   return -1;
}

int extract_word(unsigned char *block, int offset)
{
    return (block[offset] << 8) | block[offset+1];
}

void hexdump_partial(unsigned char *p, int n)
{
    for (int i=0; i<HEXDUMP_BYTES_PER_LINE; i++)
    {
        if (i<n)
        {
            printf("%02x ", p[i]);
        }
        else
        {
            printf("   ");
        }
    }
    printf("|");
    for (int i=0; i<HEXDUMP_BYTES_PER_LINE; i++)
    {
        int c = ' ';
        if (i<n)
        {
            c = p[i] & 0x7F;
            if (!isprint(c))
            {
                c = '.';
            }
        }
        printf("%c", c);
    }
    printf("|\n");
}

void hexdump(int blocknum, int offset, unsigned char *p)
{
    int logical_unit = find_logical_unit(blocknum);
    printf("%02x ", logical_unit);
    printf("%04x ", blocknum - logical_unit_offsets[logical_unit]);
    printf("%08x ", blocknum * BLOCKSIZE);
    printf("%04x ", offset);
    hexdump_partial(p+offset, HEXDUMP_BYTES_PER_LINE);
}

int file_size(struct lk_dir_entry *entry)
{
    return (entry->n_blocks - 2) * BLOCKSIZE + entry->bytes_in_last_block;
}

// verify that the block contains a valid filename

int find_filename_length(unsigned char *p)
{
    int i;
    for (i=0; i<FILENAME_SIZE; i++)
    {
        if (p[i] == 0)
        {
            break;
        }
    }
    return i;
}

int verify_filename(unsigned char *p)
{
    int len = find_filename_length(p);
    if (len == 0)
    {
        return 0;
    }
    for (int i=0; i<len; i++)
    {
        if (p[i] < 32)
        {
            return 0;
        }
    }
    return 1;
}

unsigned char sanitize_filename_char(unsigned char c)
{
    c &= 0x7F;
    if ((c == ' ') || (c == '/'))
    {
        return '_';
    }
    return c;
}

unsigned char *copy_filename(unsigned char *p)
{
    int len = find_filename_length(p);
    unsigned char *filename = malloc(len+1);
    for (int i=0; i<len; i++)
    {
        filename[i] = sanitize_filename_char(p[i]);
    }
    filename[len] = 0;
    return filename;
}

// verify that the directory entry fits known patterns

int verify_dirent(unsigned char *block)
{
    if (!verify_filename(block))
    {
        return 0;
    }
    if (extract_word(block, FILESIZE_OFFSET) == 0)
    {
        return 0;
    }
    if ((block[FILETYPE_OFFSET-1] != 0) || (block[FILETYPE_OFFSET-2] != 0))
    {
        return 0;
    }
    switch (block[HEADER_ACTIVE_OFFSET])
    {
        case 0xaf:
        case 0xac:
            break;
        default:
            return 0;
    }
    int type = block[FILETYPE_OFFSET];
    switch (type)
    {
        case 0:
            return 0;
        case PRG_FILE:
        case SEQ_FILE:
        case ML_FILE:
            return 1;
    }
    return 0;
}

struct lk_dir_entry *extract_dir_entry(int blocknum, unsigned char *block)
{
    if (verify_dirent(block))
    {
        struct lk_dir_entry *entry = malloc(sizeof(struct lk_dir_entry));
        entry->filename = copy_filename(block);

        entry->type = block[FILETYPE_OFFSET];
        entry->load_address = extract_word(block, LOADADDR_OFFSET);

        entry->bytes_in_last_block = ((block[LASTBLOCK_MSB_OFFSET] << 8) | block[LASTBLOCK_LSB_OFFSET]) & (BLOCKSIZE-1);
        if (entry->bytes_in_last_block == 0)
        {
            entry->bytes_in_last_block = BLOCKSIZE;
        }

        entry->user = (block[USER_LU_OFFSET] >> 4) & 0x0F;
	entry->logical_unit = block[USER_LU_OFFSET] & 0x0F;
        int calculated_logical_unit = find_logical_unit(blocknum);
        if (calculated_logical_unit != entry->logical_unit)
        {
            printf("Logical unit mismatch: entry %d calculated %d\n", entry->logical_unit, calculated_logical_unit);
        }

        int n_blocks =  extract_word(block, FILESIZE_OFFSET);
        entry->n_blocks = n_blocks;
        entry->block_list = malloc(sizeof(int) * entry->n_blocks);
        for (int i=0; i<n_blocks; i++)
        {
            entry->block_list[i] = extract_word(block, BLOCKLIST_OFFSET + i*2);
        }
        return entry;
    }
    return NULL;
}

void free_dir_entry(struct lk_dir_entry *entry)
{
    free(entry->filename);
    free(entry->block_list);
    free(entry);
}

struct entry_list *new_entry_list(struct lk_dir_entry *entry)
{
    struct entry_list *list = malloc(sizeof(struct entry_list));
    list->entry = entry;
    list->next = 0;
    return list;
}

void free_entry_list(struct entry_list *list)
{
    while (list != NULL)
    {
        free_dir_entry(list->entry);
        struct entry_list *next = list->next;
        free(list);
        list = next;
    }
}

// list all files in the disk image

struct entry_list *list_files(FILE *fp) 
{
    struct entry_list *first = NULL;
    struct entry_list *current = NULL;
    unsigned char block[BLOCKSIZE];
    int n = fread(block, BLOCKSIZE, 1, fp);
    int blocknum = 0;
    int valid = 0;
    while (n > 0)
    {
        if (verify_dirent(block))
        {
            hexdump(blocknum, 0, block);
            hexdump(blocknum, HEXDUMP_BYTES_PER_LINE, block);
            hexdump(blocknum, HEXDUMP_BYTES_PER_LINE*2, block);
            valid++;
        }
        struct lk_dir_entry *entry = extract_dir_entry(blocknum, block);
        if (entry != NULL)
        {
            struct entry_list *list = new_entry_list(entry);
            if (first == NULL)
            {
                first = list;
                current = list;
            }
            else
            {
                current->next = list;
                current = list;
            }
//            printf("%04x %s\n", file_size(entry), entry->filename);
//            printf("Blocks:");
//            for (int i=0; i<entry->n_blocks; i++)
//            {
//                printf(" %04x", entry->block_list[i]);
//            }
//            printf("\n");
        }

        blocknum++;
        n = fread(block, BLOCKSIZE, 1, fp);
    }
//    printf("potential files %d\n", valid);
//    printf("total blocks %d\n", blocknum);
    return first;
}

unsigned char *load_block(FILE *fp, int logical_unit, int blocknum)
{
    unsigned char *block = malloc(BLOCKSIZE);
    int absolute_block = logical_unit_offsets[logical_unit] + blocknum;
    int offset = absolute_block * BLOCKSIZE;
//    printf("Reading logical unit %d block %04x absolute block %04x file offset %08x\n", logical_unit, blocknum, absolute_block, offset);
    fseek(fp, offset, SEEK_SET);
    fread(block, BLOCKSIZE, 1, fp);
    return block;
}

unsigned char *load_data(struct lk_dir_entry *entry, FILE *fp)
{
    int size = file_size(entry);
//    printf("Loading %d bytes of data for file %s\n", size, entry->filename);
    unsigned char *buffer = malloc(size);
    unsigned char *p = buffer;
    for (int i=1; i<entry->n_blocks; i++)
    {
        unsigned char *block = load_block(fp, entry->logical_unit, entry->block_list[i]);
        int n = (i == entry->n_blocks - 1) ? entry->bytes_in_last_block : BLOCKSIZE;
        memcpy(p, block, n);
        p += n;
        free(block);
    }
    return buffer;
}

void write_file(unsigned char *data, struct lk_dir_entry *entry)
{
    char *filename = malloc(strlen((char *) entry->filename) + 7);
    sprintf(filename, "%d:%d:%s", entry->logical_unit, entry->user, entry->filename);

    FILE *out = fopen((char *) filename, "wb");

    if ((entry->type == PRG_FILE) || (entry->type == ML_FILE))
    {
        unsigned char address[2];
        address[0] = entry->load_address & 0xFF;
        address[1] = (entry->load_address >> 8) & 0xFF;
        fwrite(address, 1, 2, out);
    }

    fwrite(data, 1, file_size(entry), out);
    fclose(out);
    free(filename);
}

void show_file(unsigned char *data, struct lk_dir_entry *entry)
{
    printf("%d:%d:%s\n", entry->logical_unit, entry->user, entry->filename);
//    int size = file_size(entry);
//    for (int i=0; i<size; i+=HEXDUMP_BYTES_PER_LINE)
//    {
//        hexdump_partial(data + i, (i+HEXDUMP_BYTES_PER_LINE < size) ? HEXDUMP_BYTES_PER_LINE : size - i);
//    }
}

void extract_file(struct lk_dir_entry *entry, FILE *fp)
{
    unsigned char *data = load_data(entry, fp);
    show_file(data, entry);
    write_file(data, entry);
    free(data);
}

void extract_all(struct entry_list *list, FILE *fp)
{
    while (list != NULL)
    {
        extract_file(list->entry, fp);
        list = list->next;
    }
}

int main(int argc, char **argv)
{
    if (argc != 2)
    {
        fprintf(stderr, "Usage: %s (diskimage)\n", argv[0]);
        return 1;
    }
    FILE *fp = fopen(argv[1], "rb");
    struct entry_list *list = list_files(fp);
    
    extract_all(list, fp);

    fclose(fp);

    free_entry_list(list);
    return 0;
}

