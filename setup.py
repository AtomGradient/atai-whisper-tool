from setuptools import setup, find_packages

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setup(
    name="atai-whisper-tool",
    version="0.0.6",
    author="AtomGradient",
    author_email="alex@atomgradient.com",
    description="OpenAI Whisper with Apple MPS support",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/AtomGradient/atai-whisper-tool",
    project_urls={
        "Bug Tracker": "https://github.com/AtomGradient/atai-whisper-tool/issues",
    },
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    keywords=["audio", "whisper", "mps", "text-extraction", "audio-processing"],
    python_requires=">=3.7",
    install_requires=[
        "mlx>=0.1.1",
        "numba",
        "numpy",
        "torch",
        "tqdm",
        "more-itertools",
        "tiktoken",
        "huggingface_hub",
        "scipy"
    ],
    entry_points={
        "console_scripts": [
            "atai-whisper-tool=atai_whisper_tool.cli:main",
        ],
    },
)
