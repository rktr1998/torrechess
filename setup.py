from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize

extensions = cythonize("torrechess/**/*.pyx", force=True)

setup(
    name="torrechess",
    author="Riccardo Torreggiani",
    author_email="riccardo.torreggiani@gmail.com",
    url="https://github.com/rktr1998/torrechess",
    version="0.0.6",
    python_requires=">=3.11",
    install_requires=[],
    
    packages= ["torrechess"],

    ext_modules=extensions,
)
