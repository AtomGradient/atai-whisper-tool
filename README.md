# atai-whisper-tool

A copy of the [mlx_whisper](https://github.com/ml-explore/mlx-examples/tree/main/whisper)

**atai-whisper-tool** is a command-line tool that leverages the [OpenAI Whisper](https://github.com/openai/whisper) model with Apple MPS support for efficient audio transcription and translation. It supports multiple output formats and a wide range of languages, making it a versatile tool for speech recognition tasks.

## Features

- **Automatic Speech Recognition (ASR):** Transcribe audio files into text.
- **Speech Translation:** Translate spoken language into another language.
- **Multiple Output Formats:** Save results as plain text, JSON, SRT, VTT, TSV, or all available formats.
- **Configurable Transcription Options:** Customize parameters like model size, temperature, beam search settings, and more.
- **Support for Multiple Languages:** Auto-detect language or specify one from over 100 supported languages.
- **Apple MPS Support:** Optimized for Apple hardware using MPS for faster inference.

## Installation

Install [`ffmpeg`](https://ffmpeg.org/):

```
# on macOS using Homebrew (https://brew.sh/)
brew install ffmpeg
```

You can install the dependencies via `pip`:

```bash
pip install -r requirements.txt
```

Alternatively, if you are installing from the source distribution, ensure that you have the necessary files by including the **MANIFEST.in**:

```text
include atai_whisper_tool/whisper/assets/mel_filters.npz
include atai_whisper_tool/whisper/assets/multilingual.tiktoken
include atai_whisper_tool/whisper/assets/gpt2.tiktoken
```

### Installation from PyPI

If the package is published on PyPI, you can install it using:

```bash
pip install atai-whisper-tool
```

### ⚡️ Long audio:
Parrallel support for the whisper:
```bash
atai-whisper-tool output_bushi.wav --speedup
```

## Usage

After installation, the tool is available as a command-line utility named `atai-whisper-tool`. Run the help command to see all available options:

```bash
atai-whisper-tool -h
```

The help output will look similar to:

```plaintext
usage: atai-whisper-tool [-h] [--model MODEL] [--output-name OUTPUT_NAME] [--output-dir OUTPUT_DIR] [--output-format {txt,vtt,srt,tsv,json,all}]
                         [--verbose VERBOSE] [--task {transcribe,translate}]
                         [--language {af,am,ar,...,Yiddish,Yoruba}]
                         [--temperature TEMPERATURE] [--best-of BEST_OF] [--patience PATIENCE] [--length-penalty LENGTH_PENALTY]
                         [--suppress-tokens SUPPRESS_TOKENS] [--initial-prompt INITIAL_PROMPT] [--condition-on-previous-text CONDITION_ON_PREVIOUS_TEXT]
                         [--fp16 FP16] [--compression-ratio-threshold COMPRESSION_RATIO_THRESHOLD] [--logprob-threshold LOGPROB_THRESHOLD]
                         [--no-speech-threshold NO_SPEECH_THRESHOLD] [--word-timestamps WORD_TIMESTAMPS] [--prepend-punctuations PREPEND_PUNCTUATIONS]
                         [--append-punctuations APPEND_PUNCTUATIONS] [--highlight-words HIGHLIGHT_WORDS] [--max-line-width MAX_LINE_WIDTH]
                         [--max-line-count MAX_LINE_COUNT] [--max-words-per-line MAX_WORDS_PER_LINE]
                         [--hallucination-silence-threshold HALLUCINATION_SILENCE_THRESHOLD] [--clip-timestamps CLIP_TIMESTAMPS]
                         audio [audio ...]
```

Below is a detailed usage guide for **atai-whisper-tool** that covers the most common scenarios and explains each of the key options.

---

## Basic Usage

### 1. Transcribing Audio

**Transcription** converts spoken words in an audio file into text while preserving the original language.

- **Example:**
  ```bash
  atai-whisper-tool audio.wav
  ```
  This command uses the default model (usually `mlx-community/whisper-tiny`), transcribes the audio in `audio.wav`, and outputs the result as a text file (default format is `txt`) in the current directory.

### 2. Translating Audio

**Translation** not only transcribes the speech but also translates it into English. This is useful when the audio is in a non-English language.

- **Example:**
  ```bash
  atai-whisper-tool audio.wav --task translate
  ```
  This command will perform both transcription and translation, outputting the result in the chosen format.

---

## Key Options Explained

### Model Selection
- `--model MODEL`
  - **Description:** Specify the model directory or Hugging Face repository to use.  
  - **Default:** `mlx-community/whisper-tiny`
  - **Usage Example:**
    ```bash
    atai-whisper-tool audio.wav --model path/to/your/model
    ```

### Output Configuration
- `--output-name OUTPUT_NAME`
  - **Description:** The base name for the generated output file(s).
- `--output-dir, -o OUTPUT_DIR`
  - **Description:** Directory where the output files will be saved.
- `--output-format, -f {txt,vtt,srt,tsv,json,all}`
  - **Description:** Choose the format for your output file.
  - **Example:** To output as SRT (SubRip subtitle) file:
    ```bash
    atai-whisper-tool audio.wav --output-format srt
    ```

### Task Type
- `--task {transcribe,translate}`
  - **Description:** Choose whether to transcribe the audio (retain the original language) or translate it into English.
  - **Usage Example (Transcribe):**
    ```bash
    atai-whisper-tool audio.wav --task transcribe
    ```
  - **Usage Example (Translate):**
    ```bash
    atai-whisper-tool audio.wav --task translate
    ```

### Language Options
- `--language {list...}`
  - **Description:** Specify the language spoken in the audio. When not provided and using translation, the tool can auto-detect the language.  
  - **Example:** If you know the audio is in Spanish:
    ```bash
    atai-whisper-tool audio.wav --language es
    ```

### Verbosity and Debugging
- `--verbose VERBOSE`
  - **Description:** Control whether detailed progress and debugging messages are printed during processing.
  - **Default:** True

### Decoding & Sampling Parameters

These options allow fine-tuning of the transcription/translation process:

- `--temperature TEMPERATURE`
  - **Description:** Sampling temperature. A value of 0 means deterministic decoding.
- `--best-of BEST_OF`
  - **Description:** When using non-zero temperature, the number of candidate outputs to consider.
- `--patience PATIENCE` and `--length-penalty LENGTH_PENALTY`
  - **Description:** Advanced beam decoding parameters to control output quality.
- `--compression-ratio-threshold COMPRESSION_RATIO_THRESHOLD`  
  - **Description:** Threshold for filtering out repetitive outputs.
- `--logprob-threshold LOGPROB_THRESHOLD`  
  - **Description:** Threshold for the average log probability to decide if decoding is successful.
- `--no-speech-threshold NO_SPEECH_THRESHOLD`  
  - **Description:** Defines a threshold to determine if a segment contains speech.

### Advanced Timing & Formatting Options

For subtitle generation or word-level timing:
- `--word-timestamps WORD_TIMESTAMPS`
  - **Description:** If set, extracts detailed word-level timestamps.
- `--prepend-punctuations` and `--append-punctuations`
  - **Description:** Define punctuation handling when using word timestamps.
- `--highlight-words HIGHLIGHT_WORDS`
  - **Description:** Underlines words in subtitle outputs (requires word timestamps).
- Options like `--max-line-width`, `--max-line-count`, and `--max-words-per-line` help format the text for subtitle files.
- `--clip-timestamps CLIP_TIMESTAMPS`
  - **Description:** Process only specified clips from the audio by providing start and end timestamps (in seconds).

---

## Common Usage Examples

### Example 1: Basic Transcription with Default Settings

```bash
atai-whisper-tool audio.wav
```
- **Outcome:** Transcribes `audio.wav` using the default model and outputs a text file.

### Example 2: Transcription with Custom Output

```bash
atai-whisper-tool audio.wav --output-name my_transcript --output-dir ./transcripts --output-format json
```
- **Outcome:** Transcribes the audio file and saves the output as `my_transcript.json` in the `./transcripts` directory.

### Example 3: Translation of a Non-English Audio File

```bash
atai-whisper-tool audio.wav --task translate --language fr --output-format srt
```
- **Outcome:** Translates the French audio to English and outputs an SRT subtitle file.

### Example 4: Using Advanced Decoding Options

```bash
atai-whisper-tool audio.wav --temperature 0.2 --best-of 5 --logprob-threshold -1.0 --compression-ratio-threshold 2.4
```
- **Outcome:** Fine-tunes the transcription process with custom sampling and decoding parameters for improved quality.


## License

This project is licensed under the [MIT License](LICENSE).

