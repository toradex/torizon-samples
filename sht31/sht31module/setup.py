import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="sht31",
    version="0.0.1",
    author="Abdur Rehman",
    author_email="abdur.rehman@toradex.com",
    description="A simple module for SHT31",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://gitlab.int.toradex.com/rd/torizon-core/samples/sht31",
    packages=setuptools.find_packages(),
    install_requires=['smbus2'],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: POSIX :: Linux",
    ],
    python_requires='>=3.6',
)
