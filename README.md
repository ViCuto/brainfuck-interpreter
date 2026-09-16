<a id="readme-top"></a>

<div align="center">
  <h3 align="center">Haskell Brainfuck Interpreter</h3>
  <p align="center">
    An extended Brainfuck interpreter written in Haskell, featuring multi-program execution modes such as program concatenation, parallel execution, and alternating input streams.
  </p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#technologies-used">Technologies Used</a></li>
    <li><a href="#features">Features</a></li>
    <li><a href="#requirements">Requirements</a></li>
    <li><a href="#how-to-run">How to Run</a></li>
    <li><a href="#usage-example">Usage Example</a></li>
    <li><a href="#architecture-details">Architecture Details</a></li>
  </ol>
</details>

---

## About The Project

This project is a custom-built interpreter for the Brainfuck esoteric programming language. It goes beyond standard interpretation by introducing complex multi-program execution modes.

*Note: This project was originally developed as a course project for the Functional Programming course (2024/2025) at Sofia University (FMI).*

## Technologies Used

* **Haskell** - The core programming language used for the interpreter logic.
* **Cabal** - Used for building the project and managing dependencies.

## Features

The interpreter provides an interactive CLI menu allowing you to choose from several execution modes:

* **Standard Execution (`brainfuck`)**: Runs a single Brainfuck program.
* **Concatenation (`concat`)**: Executes two programs sequentially. The output of the first program is passed as the input to the second one.
* **Parallel Execution (`parallel`)**: Runs two programs concurrently on the exact same input stream, then combines their outputs.
* **Alternation (`alternate`)**: Alternates the execution of two programs by splitting the input stream between them.

*Note: In this implementation, the interpreter's tape works directly with integers rather than standard ASCII characters, which is ideal for testing mathematical and logic operations.*

## Requirements

To build and run this project locally, you need the official Haskell compiler (**GHC**) and the Haskell build tool (**Cabal**).

The standard and easiest way to install both is by using **ghcup** (the Haskell toolchain installer). If you don't have them set up, run the following commands

```sh
ghcup install ghc
ghcup install cabal-install
cabal update
```

## How to Run

* **To build the project**:

  Bash

  ```
  cabal build
  ```

  *(Note: The first build might take a bit longer as Cabal compiles the dependencies.)*

* **To run the interpreter**:

  Bash

  ```
  cabal run
  ```

* **Interactive Development (Optional)**:
  If you want to load the source files interactively (for debugging or testing single functions), use the REPL:

  Bash

  ```
  cabal repl
  ```

## Usage Example

Upon running the project with `cabal run`, you will be greeted by the interpreter's menu. You can test the interpreter using the provided examples in the `examples/` directory.

**Example execution (Standard Mode):**

Plaintext

```
Choose an option (enter a number 1-5):
1. brainfuck
2. concat
3. parallel
4. alternate
5. exit
1
Enter file name:
examples/countdown.bf
Enter Ints (space-separated numbers):
3
Output: [3, 2, 1]
```

## Architecture Details

* **Tape:** Uses a custom tape structure `([Int], Int, [Int])` with a size of 1000 cells to handle memory efficiently.
* **Parsing:** The Brainfuck code is fully parsed into a list of custom `BFCommand` data types before execution, ensuring efficient loop handling and bracket matching.

*For a more detailed explanation of the logic, functions, and architecture, you can check the full project documentation (available in Bulgarian) located in* *`documentary/Documentation_BG.pdf`**.*
