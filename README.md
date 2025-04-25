# BMP anaglyph generator

The BMP anaglyph generator is a tool that allows you to generate stereo monochrome image anaglyphed for red and cyan from bitmap images.

## Contents

- [Building](#building)
- [Usage](#usage)
- [Feedback]()
- [License]()

## Building

> [!IMPORTANT]
> This tool is built only for Linux platforms, for Windows and Mac users please use VMs.

### Prerequisites

- [Netwide Assembler (NASM)](https://www.nasm.us/)

### Steps

1. Clone the repository
    ```bash
    git clone https://github.com/OperandOverflow/stereo-anaglyph.git
    cd stereo-anaglyph
    ```

2. Run the script to compile source code
    ```bash
    ./build.sh
    ```

## Usage
```bash
./anaglyph <Algorithm> <Left image> <Right image> <Output image>
```
Where `<Algorithm>` can be `C` or `M`, which corresponds to Color and Mono, respectively.
Please note that all the images, both for input and ouput, must be .bmp files.

## Feedback

For any questions or feedback, please feel free to reach out to me at wangxiting01917@gmail.com.

## Licence

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.