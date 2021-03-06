# Executable and Linkable Format (ELF)
Tóm tắt nội dung, cách giải bài này đơn giản, tìm đến hàm strcmp so sánh 2 chuỗi, sau khi thực hiện hàm xong, set trực tiếp eax = 0 (fake instruction) rồi thực thi sẽ được flag   
---
- Executable and Linking Format (ELF) được phát triển và công bố bởi USL (UNIX System Laboratories) như là một phần của ABI (Application Binary Interface).  
- Ủy ban TIS (Tool Interface Standards) đã chọn chuẩn ELF làm định dạng đối tượng di động (portable object ) chạy trên môi trường kiến trúc Intel 32-bit cho nhiều hệ điều hành. 

---
## OBJECT FILES
### Introduction
- Có 3 loại object files:
    - **A relocatable file:** chứa code và dữ liệu phù hợp để liên kết với những object file khác tạo nên executable file hay shared object file.  
    - **An executable file:**  chứa chương trình phù hợp để thực thi
    - **A shared object file:** chứa code và dữ liệu phù hợp cho liên kết 2 context: 
        - Một là link editor có thể xử lý nó với những file khác và shared object file để tạo ra object file mới.  
        - Hai là dynamic linker kết nối nó với 1 file thực thi (executable file) và những shared object khác để tạo ra một process image.  
Được tạo bởi assembler và link editor, object file dạng biểu diễn nhị phân nhằm thực thi chương trình trực tiếp trên CPU.

**File Format**  
- Object file tham gia vào xây dựng chương trình (program linking) và thực thi chương trình (program executed). Do đó, để thuận tiện và hiệu quả, object file format cung cấp nhiều cách nhiều ở các góc độ khác nhau, tùy thuộc vào những yêu cầu cụ thể.
![Object_File_Format](./Images/Object_File_Format.png)  
- ELF header nằm ở vị trí bắt đầu của file, mô tả cấu trúc, tổ chức của tệp tin.
- Section giữ phần lớn thông tin tệp của các đối tượng, xem ở dạng liên kết: instruction, data, symbol table, relocation information, ...
- Program header table (nếu tồn tại) chịu trách nhiệm nói cho hệ điều hành biết làm sao để tạo một process image. Những files dùng để xây dựng process image bắt buộc phải có program header table.  
- Section header table chứa thông tin mô tả file's sections. Mỗi section có một entry trong table, và mõi entry sẽ chứa những thông tin như: tên section, kích thước,... Những file được sử dụng trong quá trình linking thì phải có cùng section header table.  
**Data Representation**  
- Như nói ở trên, Object file format hỗ trợ các bộ xử lí khác nhau với kiến trúc 4 bytes, 32 bits. HƠn nữa, nó có xu hướng mở rộng đến các kiến trúc lớn hơn (hoặc nhỏ hơn). Do đó, object file trình bày một số control data với format độc lập với máy tính để có thể xác định object files và thông dịch nôi dung của chúng một cách chung nhất. Phần dữ liệu còn lại trong object files sử dụng mã hóa của bộ xử lí đích (target processor).  
- Tất cả những cấu trúc dữ liêu được định dạng trong file object đều phải tuân theo nguyên tắc căn chỉnh (alignment guidelines) và kích thước "tự nhiên" cho những lớp liên quan. Nếu cần thiết, ta sử dụng những byte đệm (padding) để đảm bảo sự căn chỉnh, và dữ liệu cần phải đươc căn chỉnh phù hợp ngay từ đầu file.

### ELF Header    
- Chứa kích thước thực của object file.  
- Khi cấu trúc object file thay đổi thì hệ thống sẽ tính lại control struct.  
```c
#define EI_NIDENT       16

typedef struct {
    unsigned char   e_ident[EI_NIDENT];
    Elf32_Half      e_type;
    Elf32_Half      e_machine;
    Elf32_Word      e_version;
    Elf32_Addr      e_entry;
    Elf32_Off       e_phoff;
    Elf32_Off       e_shoff;
    Elf32_Word      e_flags;
    Elf32_Half      e_ehsize;
    Elf32_Half      e_phentsize;
    Elf32_Half      e_phnum;
    Elf32_Half      e_shentsize;
    Elf32_Half      e_shnum;
    Elf32_Half      e_shstrndx;
}
```
- **e_ident** byte đánh dấu file là 1 object file và cung cấp những dữ liệu độc lập với máy để giải mã và thông dịch nội dung của file.  
- **e_type** xác định loại object file  

| Name      | Value     | Meaning               |
| :---:     | :---:     | :---:                 |
| ET_NONE   | 0         | No file type          |
| ET_REL    | 1         | Relocatable file      |
| ET_EXEC   | 2         | Executable file       |
| ET_DYN    | 3         | Shared object file    |
| ET_CORE   | 4         | Core file             |
| ET_LOPROC | 0xff00    | Processor-specific    |
| ET_HIPROC | 0xffff    | Processor-specific    |  

- **e_machine** giá trị của trường này chỉ định kiến trúc cụ thể mà file yêu cầu.  

| Name      | Value | Meaning       |
| :---:     | :---: | :---:         |
| EM_NONE   | 0     | No machine    |
| EM_M32    | 1     | AT&T WE 32100 |
| EM_SPARC  | 2     | SPARC         |
| EM_386    | 3     | Intel 80386   |
| EM_68K    | 4     | Motorola 68000|
| EM_88K    | 5     | Motorola 88000|
| EM_860    | 7     | Intel 80860   |
| EM_MIPS   | 8     | MIPS RS3000   |

- **e_version** như tên gọi, trường này xác định version của object file

| Name          | Value | Meaning           |
| :---:         | :---: | :---:             |
| EV_NONE       | 0     | Invalid version   |
| EV_CURRENT    | 1     | Current version   |

Khi có những version cao hơn, nếu cần thiết, giá trị *EV_CURRENT* sẽ thay đổi tương ứng với verison hiện tại.
- **e_entry**  trường này đưa ra địa chỉ ảo (virtual address) nơi mà hệ thống chuyển quyền điều khiển để bắt đầu tiến trình. Nếu file không có ngõ vào tương ứng, trường này sẽ có giá trị là 0 
- **e_phoff** phoff là viết tắt của program header table's file offset, nên trường này giữ giá tri của program header table's file offset ở dạng byte.
- **e_shoff** giữ giá trị của section header table's file offset dạng byte.
- **e_flags** giữ các cờ đặc trưng của bộ xử lí và liên kết với tệp. Tên của cờ có dạng "EF_machine_flag".  
- **e_ehsize**: chứa kích thước của ELF header dạng bytes.
- **e_phentsize**: chứa kích thước của 1 entry trong bảng program header của file, và tất cả entry đều có cùng 1 kích thước.  
- **e_phnum**: giữ số lượng entry trong bảng program header của têp.
- **e_shnum**: số lượng entry trong bảng section header của tệp.  
- **e_shstrndx**: giữ chỉ mục của bảng section header liên kết với bảng section name string  
#### ELF Identification
- Elf cung cấp một object file framework để hỗ trợ multiple processor, multiple data encoding và multiple classes của máy. Để hỗ trợ cho họ object file này. những byte khởi tạo của file sẽ đặc tả cách thông dịch file, chúng độc lập với bộ xử lí đang thực hiện và phần nội dung còn lại của file. 
- Những byte khởi tạo này tương ứng với trường e_ident trong cấu trúc ELF header  

| Name          | Vale  | Purpose                   |
| :---:         | :---: | :---:                     |
| EI_MAG0       | 0     | File identifcation        | 
| EI_MAG1       | 1     | File identifcation        | 
| EI_MAG2       | 2     | File identifcation        |
| EI_MAG3       | 3     | File identifcation        |
| EI_CLASS      | 4     | File Class                | 
| EI_DATA       | 5     | Data encoding             | 
| EI_VERSION    | 6     | File Version              |
| EI_PAD        | 7     | Start of padding bytes    |
| EI_NIDENT     | 16    | Size of e_ident[]         | 

Những index này trỏ tới những byte lưu các giá trị tương ứng. Chúng ta sẽ tìm hiểu cụ thể ý nghĩa của các index.  
- **EI_MAG0 - EI_MAG3**: 4 bytes đầu tiên chứa những "magic number" để xác nhận tệp có dạng ELF object. 

| Name      | Value | Position          |
| :---:     | :---: | :---:             |
| ELFMAG0   | 0x7f  | e_ident[EI_MAG0]  |
| ELFMAG1   | 'E'   | e_ident[EI_MAG1]  |
| ELFMAG2   | 'L'   | e_ident[EI_MAG2]  |
| ELFMAG3   | 'F'   | e_ident[EI_MAG3]  | 

- **EI_CLASS**: Byte kế tiếp, e_ident[EI_CLASS] nhận diện file class hoặc sức chứa (capacity)

| Name          | Value | Position       |
| :---:         | :---: | :---:          |
| ELFCLASSNONE  | 0     | Invalid Class  |
| ELFCLASS32    | 1     | 32-bit object  |
| ELFCLASS64    | 2     | 64-bit object  |
    - Định dạng tệp được thiết kế để linh hoạt giữa các máy với kích thước khác nhau mà không cần đặt kích thước của máy lớn nhất lên máy nhỏ nhất.
    - **ELFCLASS32** hỗ trợ cho những máy có không gian địa chỉ và tệp tin lên đến 4GB. 
    - **ELFCLASS64** giành cho kiến trúc 64 bit. NÓ cho thấy object file có thể thay đổi kích thước, tuy nhiên định dạng 64-bit không thể xcas định được.
    - Khi cần thiết, có thể định nghĩa thêm những class khác với kiểu dữ liệu và kích thước khác cho object file.
- **EI_DATA** Byte *e_ident[DI_DATA]* chỉ định cách mã hóa dữ liệu dành riêng cho bộ xử lý trong object file.  

| Name          | Value | Meaning                   |
| :---:         | :---: | :---:                     |
| ELFDATANONE   | 0     | Invalid data encoding     |
| ELFDATA2LSB   | 1     | Least significant byte    |
| ELFDATA2MSB   | 2     | Most significant byte     |

- **EI_VERSION**: byte *e_ident[EI_VERSION]* chỉ định số phiên bản của ELF header, thường nó có giá trị là *EV_CURRENT*  
- **EI_PAD**: Bắt đầu cho chuỗi những byte có không sử dụng trong e_ident. Các byte này được để riêng (reversed) và có giá trị là 0. Giá trị EI_PAD sẽ thay đổi trong tương lai nếu những byte này được sử dụng.  
- **Machine Information**: Với kiến trúc Intel 32 bit, giá trị file identification trong e_ident sẽ là:  

| Position          | Value         |
| :---:             | :---:         |
| e_ident[EI_CLASS] | ELFCLASS32    |
| e_ident[EI_DATA]  | ELFDATA2LSB   |
    - Bộ xử lí nhận e_machine nằm trong ELF header's và phải có giá trị là EM_386 
    - Trong e_flags giữ những bit flag liên kết với tệp. Trường hợp kiến trúc không có flag (như Intel 32 bit) trường này chứa 0.


### Sections
- Bảng section header là một mảng các cấu trúc Elf32_shdr và một section header table index là một chỉ số con trong mảng đó.  
- Phần tử *e_shoff* của ELF header đưa ra byte offset từ đầu file đến section header table; *e_shnum* cho ta biets có bao nhiêu entries trong bảng section header và *e_shentsize* cho biết kích thước của mỗi entry.  
- Một số chỉ mục (indexes) của bảng section header được giữ lại (reserved) và một object file sẽ không có section cho những địa chỉ đặc biệt này.  

| Name          | Value     |
| :---:         | :---:     |
| SHN_UNDEF     | 0         |
| SHN_LORESERVE | 0Xff00    | 
| SHN_LORPOC    | 0xff00    |
| SHN_HIPROC    | 0xff1f    |
| SHN_ABS       | 0xfff1    |
| SHN_COMMON    | 0xfff2    |
| SHN_HIRESERVE | 0xffff    |

Trong đó:  
**SHN_UNDEF**: Đánh dấu các tham chiếu (reference) không xác định, thiếu, vô nghĩa hoặc không liên quan.  
**SHN_LORESERVE**: giới hạn dưới của reserved indexes  
**SHN_LOPROC tới SHN_HIPROC**: Các giá trị trong phạm vi này được giành riêng cho ngữ nghĩa cụ thể của bộ xử lý.  
**SHN_ABS**: chỉ định các giá trị tuyệt đối cho hàm tham chiếu tương ứng.  
**SHN_COMMON**: chỉ rõ các ký hiệu (Symbol) được xác định liên quan đến section này đều là kí hiệu chung.  
**SHN_HIRESERVE**: giới hạn trên của reserved indexes  

- Section chứa tất cả thông tin của object file, ngoại trừ ELF header, program header table, the section header table. Ngoài ra, section cảu object file còn thỏa mãn một số điều kiện:
    * Mỗi section trong một object file có chính xác một section header mô tả nó. Section header có thể tồn tại mà không có section.  
    * Mỗi section chiếm một chuỗi byte liên tiếp (có thể rỗng) bên trong file.
    * Các section trong một tệp không được trùng lặp, không có byte nào trong tệp nằm nhiều hơn một section.  
    * Một object file có thể có không gian khồng hoạt động (inactive space). Các headers và sections khác nhau có thể không bao phủ tất cả các byte trong object file và nội dung dữ liệu của inactive space là không xác định được.  
- Một section header có cấu trúc như sau:

```c
    typedef struct {
        Elf32_Word          sh_name;
        Elf32_Word          sh_type;
        Elf32_Word          sh_flags;
        Elf32_Addr          sh_addr;
        Elf32_Off           sh_offset;
        Elf32_Word          sh_size;
        Elf32_Word          sh_link;
        Elf32_Word          sh_info;
        Elf32_Word          sh_addralign;
        Elf32_Word          sh_entsize;
    } Elf32_Shdr;
```

Trong đó:  
    - **sh_name**: Chỉ định tên của section. Giá trị của nó là 1 index trong bảng section header string.  
    - **sh_type**: giá trị này dùng để phân loại các sections dựa trên nội dung và ngữ nghĩa của nó.  
    - **sh_flags**: Các section dùng 1 bit này để mô tả các thuộc tính khac   
    - **sh_addr**: Nếu section xuất hiện trong memmory image of process thì trường này lưu trữ địa chỉ của byte đầu tiên của section, ngược lại nó có giá trị 0.  
    - **sh_offset**: lưu byte offset từ đầu file đến bye đầu tiên của section.  
    - **sh_size**: Lưu kích thước section (đơn vị byte). Trường hợp section có type là *SHT_NOBITS*, mắc dù có kích thước khác 0 nhưng nó lại không chiếm không gian trên vùng nhớ.  
    - **sh_link**: Giữ liên kết chỉ mục của bảng section header, dùng để chỉ định cách thông dịch (intepretation)  
    - **sh_info**: Lưu thông tin mà thông dịch được.  
    - **sh_addralign**: Giành cho những ràng buộc về căn chỉnh (alignment constraints). Giá trị 0 và 1 muốn nói section này không có  những ràng buộc ngữ nghĩa.  
    - **sh_entsize**: Một số section lưu giữ những bảng có số entries là cố định (ví dụ: symbol table), với những section kiểu nayfm *sh_entsize* sẽ cho biết kích thước của mỗi entry trong bảng. Trường hợp file không có những section như trên, *sh_entsize* sẽ có giá trị là 0.

- Nói rõ hơn về trường **sh_type** của section header. Nó bao gồm:
    
    | Name | Value |
    | :--: | :---: |
    | SHT_NULL | 0 |
    | SHT_PROGBITS | 1 |
    | SHT_SYMTAB | 2 | 
    | SHT_STRTAB | 3 |
    | SHT_RELA | 4 |
    | SHT_HASH | 5 |
    | SHT_DYNAMIC | 6 |
    | SHT_NOTE | 7 |
    | SHT_NOBITS | 8 | 
    | SHT_REL | 9 |
    | SHT_SHLIB | 10 |
    | SHT_DYNSYM | 11 |
    | SHT_LOPROC | 0x70000000 |
    | SHT_HIPROC | 0x7fffffff |
    | SHT_LOUSER | 0x80000000 |
    | SHT_HIUSER | 0xffffffff |

    - **SHT_NULL**: cho thấy section header inactive, nó không có section liên quan và những trường khác của section header cũng không có giá trị xác định (undefined values).  
    - **SHT_PROGBITS**: giữ những thông tin được định nghĩa bởi chương trình, và chỉ chương trình mới định nghĩa định dạng và ý nghĩa của phần này.  
    - **SHT_SYMTAB và SHT_DYNSYM**: lưu giữ bảng các symbols (symbols table). Hiện nay, mỗi object file chỉ có một symbol table, tuy nhiên con số này có thể tăng lên trong tương lại.
    Về cơ bản, *SHT_SYMTAB* cung cấp những symbols để chỉnh sử liên kết. Mặc dù điều này hoàn toàn cỏ thể thực hiện bằng liên kết động (dynamic linking), tuy nhiên trong symbol table, có thể có nhiều symbol không thực sự cần thiết cho liên kết động. Việc này cũng là nguyên nhân có trường *SHT_DYNSYM* là tập tối thiểu chứa các symbol liên kết động để tiết kiện không gian.  
    - **SH_STRTAB**: giữ string table. Một object file có thể có nhiều string table sections.  
    - **SHT_RELA**: chứa các mục chuyển vị trí (relocation entries) với các phụ đề rõ ràng. Ví dụ: Elf32_Rela cho lớp 32 bit của object files. Một object file có thể có nhiều relocation sections.  
    - **SHT_HASH**: Chứa bảng symbol hash. Tất cả những object tham gia vào dynamic linking phải có một bảng symbol hash. Hiện nay, một object file chỉ có thể có một hash table, nhưng con số này có thể tăng lên trong tương lai.  
    - **SHT_DYNAMIC**: chứa thông tin của dynamic linking. Hiện nay 1 object file cũng chỉ có thể chứa 1 dynamic section, nhưng con số này có thể tăng lên truong tương lai.  
    - **SHT_NOTE**: chứa thông tin đánh dấu file theo một cách nào đó (và tôi cũng chưa biết cách nào đó là cách gì) 
    - **SHT_NOBITS**: Giống như SHT_PROGBITS nhưng lại không chiếm không gian trong file. Mặc dù phần này là 0 byte nhưng *sh_offset*  lại chứa offset định nghĩa về nó.  
    - **SH_REL**: giống như *SH_RELA* nhưng không có các phụ đề rõ ràng. Ví dụ *ELF32_Rel* cho lớp 32 bit của object files. Một object file có thể có nhiều relocation section.  
    - **SHT_HLIB**: loại section này được giành riêng (reserved) nhưng có ngữ nghĩa không xác định. Chương trình có loại section này thì không cần tuân theo ABI (Application Binary Interface).  
    - **SHT_LOPROC đến SHT_HI_PROC**: giá trị trong khoảng này được giành riêng cho ngữ nghĩa cụ thể của từng bộ xử lí.  
    - **SHT_LOUSER**: cận dưới của dải index giành riêng cho các chương trình ứng dụng.  
    - **SHT_HIUSER**: cận trên của dải index giành riêng cho các chương trình ứng dụng. Những loại section nằm giữa *SHT_LOUSER* và *SHT_HIUSER* có thể được sử dụng bởi ứng dụng mà không bị conflict với những loại section do hệ thống định nghĩa trong hiện tại và tương lai  
    Những giá trị của các loại section khác được reserved. Như đã nói về sự tồn tại của section header với index 0 (SHN_UNDEF), mặc dù index này đánh dấu cho những undefined section references. Entry này như sau:

    | Name | Value | Note |
    | :--: | :---: | :---: |
    | sh_name | 0 | Noname|
    | sh_type | SHT_NULL | Inactive |
    | sh_flags | 0 | No flags |
    | sh_addr | 0 | No address |
    | sh_offset | 0 | No file offset |
    | sh_size | 0 | No size |
    | sh_link | SHN_UNDEF | No link information |
    | sh_info | 0 | No auxiliary information |
    | sh_addralign | 0 | No alignment |
    | sh_entsize | 0 | No entries |

    - Section header's *sh_flags* dùng 1 bit để mô tả các tính chất của section (on/off)  

    | Name | Value |
    | :---: | :---: |
    | SHF_WRITE | 0x1 |
    | SHF_ALLOC | 0x2 |
    | SHF_EXECINSTR | 0x4 |
    | SHF_MASKPROC | 0xf0000000 |

    **SHF_WRITE**: chứa dữ liệu được ghi trong suốt quá trình thực thi process.  
    **SHF_ALLOC**: cấp phát vùng nhớ trong quá trinh thực thi process. Thuộc tính này sẽ tắt một số phần điuề khiển không nằm trong memory image của object file.  
    **SHF_EXECINSTR**: chứa tập lệnh thực thi của máy.  
    **SHF_MASKPROC**: Tất cả những bit có trong mặt nạ (mask) này được giành riêng cho ngữ nghĩa cụ thể của bộ xử lý.  
- **sh_link và sh_info** giữ những thông tin đặc biệt tùy thuộc theo loại section.  

| sh_type | sh_link | sh_info |
| :---: | :---: | :---: |
| SHT_DYNAMIC | index của section header trong string table được sử udngj bởi entries trong section | 0 |
| SHT_HASH | index của secton header trong symbol table mà hash table áp dụng | 0 |
| SHT_RET SHT_RELA | index của section trong header này lien eketes với symbol table | index của section header được áp dụng bới relocation applies |
| SHT_SYMTAB SHT_DYNSYM | index của section header này được string table áp dụng | Một số lớn hơn chỉ số symbol table của ký hiệu cục bộ cuối cùng (binding STB_LOCAL) | 
| Other | SHN_UNDEF | 0 |

- **Special Sections**: Nhiều section chứa thông tin của program và control. Một số section sau đây được dùng bởi hệ thống.  

| Name | Type | Attributes |
| :---: | :---: | :---: |
| .bss | SHT_NOBITS | SHF_ALLOC + SHF_WRITE |
| .comment | SHT_PROGBITS | None |
| .data | SHT_PROGBITS | SHF_ALLOC + SHF_WRITE |
| .data1 | SHT_PROGBITS | SHF_ALLOC + SHF_WRITE |
| .debug | SHT_PROGBITS | None | 
| .dynamic | SHT_DYNAMIC | Trình bày sau |
| .dynstr | SHT_STRTAB | SHF_ALLOC |
| .fini | SHT_PROGBITS | SHF_ALLOC + SHF_EXECINSTR |
| .got | SHT_PROGBITS | trình bày sau |
| .hash | SHT_HASH | SHF_ALLOC |
| .init | SHT_PROGBITS | SHF_ALLOC + SHF_EXECINSTR |
| .interp | SHT_PROGBITS | SHF_ALLOC + SHF_EXECINSTR |
| .line | SHT_PROGBITS | None |
| .note | SHT_NOTE | None |
| .plt | SHT_PROGBITS | Trình bày bên dưới |
| .relname | SHT_REL | Trình bày bên dưới |
| .relaname | SHT_RELA | Trình bày bên dưới |
| .rodata | SHT_PROGBITS | SHF_ALLOC |
| .rodata1 | SHT_PROGBITS | SHF_ALLOC |
| .shstrtab | SHT_STRTAB | None |
| .strtab | SHT_STRTAB | Xem ở dưới |
| .symtab | SHT_SYMTAB | Xem ở dưới |
| .text | SHT_PROGBITS | SHF_ALLOC + SHF_EXECINSTR | 

    - **.bss**: Phần này chứa dữ liệu chưa được khởi tạo trong memory image của chương trình. Theo định nghĩa, hệ thống sẽ khởi tạo dữ liệu với giá trị là 0 khi chương trình bắt đầu chạy, và nó không chiếm không gian file, vì có kiểu là *SHT_NOBITS*  
    - **.comment**: Lưu trữ thông tin kiểm soát phiên bản (version control).  
    - **.data và .data1**: chứa dữ liệu đã được khởi tạo, được sử dụng trong memory image của chương trình.  
    - **.debug**: Chứa thông tin cho symbolic debugging. Nội dung này không xác định. 
    - **.dynamic**: giữ thông tin về dynamic linking. Thuộc tính ở phần này sẽ bao gồm *SHF_ALLOC* bit.  
    - **.dynstr**: giữ những string cần thiết cho dynamic linking. Phổ biến nhất là các string đại diện cho tên được liên kết với các symbol table entries.  
    - **.dynsym**: giữa dynamic linking symbol table.  
    - **.fini**: giữ những lệnh thực thi góp phần vào mã kết thúc quá trinh. Nghĩa là khi chương trình kết thúc một cách bình thường, hệ thống sẽ thực thi code ở phần này.  
    - **.got**: giữa global offset table.  
    - **.hash**: giữ symbol hash table.  
    - **.init**: giữ những lệnh thực thi cho quá trình khởi tạo. Nghĩa là khi chương trình bắt đầu chạy thì code trong phần này thực thi trước khi vào hàm entry point chính của chương trình.  
    - **.interp**: Phần này chứa tên đường dẫn của trình thông dịch chương trình. Nếu file có một phân đoạn có thể tải được phần này thì các thuộc tính của phần này sẽ có cả *SHF_ALLOC bit* nếu không bit này sẽ tắt.  
    - **.line**: Giữ thông tin về số dòng cho symbolic debuggin ánh xạ tương ứng giữa source code chương trình với tên mã máy tương ứng. Nội dung không xác định.  
    - **.note**: Giữ thông tin có dạng "Note Section"   
    - **.plt**: giữ procedure linkage table.  
    - **.relname và .relaname** giữ thông tin relocation. Nếu tệp có một phân doạn có thể tải được relocation, các thuộc tính cảu sexction sẽ có cả *SHF_ALLOC* bit, nếu không bit này sẽ tắt. Thông thường, tên được cung cấp bởi khu vực và relocation áp dụng. Do đó, một phần relocation cho .text thông thường có tên .rel.text hoặc .rela.text  
    - **.rodata và .rodata1**: giữ những dữ liệu chỉ đọc và khổng thể viết trong process image.  
    - **.shstrtab**: giữ các tên của section  
    - **.strtab**: giữ các string, phổ biến nhất là các tring đại diện cho tên được liên kết với các symbol table entries. Nếu tệp có một phân đoạn có thể tải được symbol string table, các thuộc tính của section sẽ có thêm *SHF_ALLOC bit*, ngược lại bit này sẽ tắt.  
    - **.text**: section này giữ "text" hoặc lệnh thực thi của chương trình.  
- Dễ dàng thấy tên section có tiền tố `.` ở trước và giành riêng cho hệ thống. Tuy nhiên, ứng dụng vẫn có thể sử dụng những chuỗi này. Khi đó, ứng dụng sẽ dùng tên mà không có tiền tố để tránh xung đột với section của hệ thống. Object file format cho phép định nghĩa thêm những section không nằm trong list trên, 1 object file có thể có nhiều hơn 1 section cùng tên.  
- Tên section giành riêng cho kiến trúc bộ xử lý, được hình thành bằng cách đtặ tên viết tắt của kiến trúc trước tên section. Tên lấy được từ kiến trúc sử dụng cho **e_machine**. Ví dụ `.FOO.psect` được định nghĩa bởi kiến trúc FOO. Các tiện ích mở rông hiện tại được gọi theo tên lịch sử của chúng. 

| Pre-existing Extensions |
| :---:  |
| .sdata |
| .sbss |
| .lit8 |
| .gptab |
| .conflict |
| .toless | 
| .lit4 |
| .reginfo |
| .liblist |


### String Table
- String table sections chứa chuỗi các ký tự kết thúc bằng NULL, chúng ta thường gọi là string.  
- Object file thường dùng những string này để biểu diễn các symbol và section name. Một tham chiếu đến một chuỗi sẽ có dạng một index trỏ đến string table section.  
- Byte đầu tiên và byte cuối cùng của string table là kí tự NULL. Một chuỗi chỉ có có index 0 thể hiện đối tượng này không tên, tên rỗng hoặc một ý nghĩa khác tùy thuộc vào ngữ cảnh.  
- String table cho phép tồn tại empty string. Khi đó, *sh_size* trong section header có giá trị là 0 và những index khác 0 trong bảng sẽ không hợp lệ.  
- *sh_name* trong section header giữ index trỏ tới section header string table section do *e_shstrndx* chỉ định. Ví dụ như hình sau:  

![StringTableEx.png](./Images/StringTableEx.png)  

![stringTableEx2.png](./Images/stringTableEx2.png)

- Trong ví dụ trên, ta có thể thấy rằng một  index của string table có thể trỏ đến bất kì byte nào trong section. Một string có thể xuất hiện nhiều lần; có thể tham chiếu đén một chuỗi con. Một single string có thể được tham chiếu nhiều lần, và những chuỗi không tham chiếu cũng được chấp nhận.  
 





### Symbol Table
### Relocation

---
## PROGRAM LOADING AND DYNAMIC LINKING

---
