#!/bin/bash
# This script splits an audio file into segments, processes each with atai-whisper-tool,
# and then merges the transcripts in the correct order.
#
# If the total audio duration is less than 300 seconds, no splitting is done.
# Otherwise, SEGMENT_DURATION is computed as:
#   SEGMENT_DURATION = (Total Audio Duration) / (Number of CPU cores)
# 
# need install:parrallel,ffmpeg, you can use brew to install them

# Check for required input arguments
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <audio_file>"
    exit 1
fi

AUDIO_FILE="$1"

# Check if ffmpeg and ffprobe are installed
if ! command -v ffmpeg > /dev/null 2>&1 || ! command -v ffprobe > /dev/null 2>&1; then
    echo "Error: ffmpeg (with ffprobe) is not installed. Please install ffmpeg and try again."
    exit 1
fi

# Determine the total duration of the audio file (in seconds) using ffprobe.
AUDIO_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$AUDIO_FILE")
if [ -z "$AUDIO_DURATION" ]; then
    echo "Error: Unable to determine audio duration."
    exit 1
fi

# Determine the number of CPU cores.
if command -v nproc >/dev/null 2>&1; then
    CORES=$(nproc)
else
    CORES=$(sysctl -n hw.ncpu)
fi

# Compute SEGMENT_DURATION:
# If the total audio duration is less than 300 seconds, process the entire file as one segment.
# Otherwise, compute SEGMENT_DURATION = (audio_duration / cores), with a minimum of 300 seconds.
if (( $(echo "$AUDIO_DURATION < 300" | bc -l) )); then
    SEGMENT_DURATION=$(printf "%.0f" "$AUDIO_DURATION")
else
    SEGMENT_DURATION=$(awk -v duration="$AUDIO_DURATION" -v cores="$CORES" 'BEGIN { printf "%d", duration/cores }')
fi

echo "Audio Duration: ${AUDIO_DURATION} seconds"
echo "CPU cores: ${CORES}"
echo "SEGMENT_DURATION set to: ${SEGMENT_DURATION} seconds"

# Create directories for audio segments and transcripts.
SEGMENT_DIR="audio_segments"
TRANSCRIPT_DIR="transcripts"
mkdir -p "$SEGMENT_DIR" "$TRANSCRIPT_DIR"

# Split the audio file into segments.
# If the audio is shorter than SEGMENT_DURATION (i.e. less than 300 seconds), ffmpeg will output one segment.
echo "Splitting '$AUDIO_FILE' into segments of ${SEGMENT_DURATION} seconds..."
ffmpeg -i "$AUDIO_FILE" -f segment -segment_time "$SEGMENT_DURATION" -c copy "$SEGMENT_DIR/segment_%03d.wav"
if [ $? -ne 0 ]; then
    echo "Error: Failed to split the audio file."
    exit 1
fi

echo "Transcribing segments with atai-whisper-tool..."
echo "Processing segments in parallel without GNU Parallel..."
for segment in $(ls "$SEGMENT_DIR"/*.wav | sort); do
    (
        basename=$(basename "$segment" .wav)
        echo "Processing segment: $segment"
        sleep 1
        atai-whisper-tool "$segment" --output-dir "$TRANSCRIPT_DIR" --output-name "$basename" --output-format txt || \
            echo "Warning: Failed to transcribe segment $segment"
    ) &
done

wait

# Merge all transcript files into one final transcription file.
MERGED_FILE="final_transcription.txt"
rm -f "$MERGED_FILE" 2>/dev/null
echo "Merging transcript files in order..."
for transcript in $(ls "$TRANSCRIPT_DIR"/*.txt | sort); do
    cat "$transcript" >> "$MERGED_FILE"
    echo -e "\n" >> "$MERGED_FILE"
done

echo "Final transcription saved to '$MERGED_FILE'."

rm -rf "$SEGMENT_DIR" "$TRANSCRIPT_DIR"
echo "Cleanup complete."