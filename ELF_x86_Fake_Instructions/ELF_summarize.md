# Executable and Linkable Format (ELF)
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
- ELF header nằm ở vị trí bắt đầu của file, mô tả cấu trúc, tổ chức của têp tin.
- Section giữ phần lớn thông tin tệp của các đối tượng, xem ở dạng liên kết: instruction, data, symbol table, relocation information, ...
- Program header table (nếu tồn tại) chịu trách nhiệm nói cho hê điều hành biết làm sao để tạo môt process image. Những files dùng để xây dựng process image bắt buộc phải có program header table.  
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
| e_ient[EI_DATA]   | ELFDATA2LSB   |
    - Bộ xử lí nhận e_machine nằm trong ELF header's và phải có giá trị là EM_386 
    - Trong e_flags giữ những bit flag liên kết với tệp. Trường hợp kiến trúc không có flag (như Intel 32 bit) trường này chứa 0.


### Sections
### String Table
### Symbol Table
### Relocation