# distutils: language = c++
# cython: language_level = 3

from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp cimport bool

# Define global constants and the getters for Python access for useful constants
cdef string PIECE_NAME_WHITE_PAWN = b'P' # must be bytes
cdef string PIECE_NAME_WHITE_KNIGHT = b'N'
cdef string PIECE_NAME_WHITE_BISHOP = b'B'
cdef string PIECE_NAME_WHITE_ROOK = b'R'
cdef string PIECE_NAME_WHITE_QUEEN = b'Q'
cdef string PIECE_NAME_WHITE_KING = b'K'
cdef string PIECE_NAME_BLACK_PAWN = b'p'
cdef string PIECE_NAME_BLACK_KNIGHT = b'n'

cdef string PIECE_NAME_BLACK_BISHOP = b'b'
cdef string PIECE_NAME_BLACK_ROOK = b'r'
cdef string PIECE_NAME_BLACK_QUEEN = b'q'
cdef string PIECE_NAME_BLACK_KING = b'k'
cdef string PIECE_NAME_EMPTY_SQUARE = b'.'

cdef string DEFAULT_FEN = b'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1' # full initial chess position FEN
cdef string DEFAULT_FEN_BOARD = b'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR' # only the board part


# Define functions
cpdef get_default_fen():
    return DEFAULT_FEN.decode('utf-8') # decode bytes to utf-8 before returning to Python

cpdef get_default_fen_board():
    return DEFAULT_FEN_BOARD.decode('utf-8')

cdef bool is_digit(char c):
    return c == b'0' or c == b'1' or c == b'2' or c == b'3' or c == b'4' or c == b'5' or c == b'6' or c == b'7' or c == b'8' or c == b'9' # lol

cpdef print_pretty_bitmask(unsigned long long bitmask):
    """
    Visualize the given bitmask as an 8x8 board.
    The first square is bottom left.
    """
    cdef int row, col
    for row in range(7, -1, -1):  # Start from the top row and go to the bottom row
        for col in range(8):
            if bitmask & (1 << (row * 8 + col)):
                print('1 ', end='')
            else:
                print('0 ', end='')
        print()


cpdef get_bitmask_string(unsigned long long bitmask):
    """
    Get the given bitmask as a string of 64 characters.
    """
    cdef string s = b''
    for i in range(64):
        if bitmask & (1 << i):
            s.append(b'1')
        else:
            s.append(b'0')

    return s.decode('utf-8')

# Define the Board class
cdef class Board:
    cdef unsigned long long bitmask_white_pawn
    cdef unsigned long long bitmask_white_knight
    cdef unsigned long long bitmask_white_bishop
    cdef unsigned long long bitmask_white_rook
    cdef unsigned long long bitmask_white_queen
    cdef unsigned long long bitmask_white_king

    cdef unsigned long long bitmask_black_pawn
    cdef unsigned long long bitmask_black_knight
    cdef unsigned long long bitmask_black_bishop
    cdef unsigned long long bitmask_black_rook
    cdef unsigned long long bitmask_black_queen
    cdef unsigned long long bitmask_black_king

    # Define constructor overload for FEN string
    def __init__(self, str fen):
        self.bitmask_white_pawn = 0
        self.bitmask_white_knight = 0
        self.bitmask_white_bishop = 0
        self.bitmask_white_rook = 0
        self.bitmask_white_queen = 0
        self.bitmask_white_king = 0

        self.bitmask_black_pawn = 0
        self.bitmask_black_knight = 0
        self.bitmask_black_bishop = 0
        self.bitmask_black_rook = 0
        self.bitmask_black_queen = 0
        self.bitmask_black_king = 0

        self.load_fen_board(fen)
    
    # Define the destructor
    #def __dealloc__(self):
    #    pass
    
    # Define getters for pieces bitmasks
    cpdef unsigned long long get_bitmask_white_pawn(self):
        return self.bitmask_white_pawn
    cpdef unsigned long long get_bitmask_white_knight(self):
        return self.bitmask_white_knight
    cpdef unsigned long long get_bitmask_white_bishop(self):
        return self.bitmask_white_bishop
    cpdef unsigned long long get_bitmask_white_rook(self):
        return self.bitmask_white_rook
    cpdef unsigned long long get_bitmask_white_queen(self):
        return self.bitmask_white_queen
    cpdef unsigned long long get_bitmask_white_king(self):
        return self.bitmask_white_king

    cpdef unsigned long long get_bitmask_black_pawn(self):
        return self.bitmask_black_pawn
    cpdef unsigned long long get_bitmask_black_knight(self):
        return self.bitmask_black_knight
    cpdef unsigned long long get_bitmask_black_bishop(self):
        return self.bitmask_black_bishop
    cpdef unsigned long long get_bitmask_black_rook(self):
        return self.bitmask_black_rook
    cpdef unsigned long long get_bitmask_black_queen(self):
        return self.bitmask_black_queen
    cpdef unsigned long long get_bitmask_black_king(self):
        return self.bitmask_black_king
    
    # Define method to reset all bitmasks to 0
    cpdef void reset_all_bitmasks(self):
        self.bitmask_white_pawn = 0
        self.bitmask_white_knight = 0
        self.bitmask_white_bishop = 0
        self.bitmask_white_rook = 0
        self.bitmask_white_queen = 0
        self.bitmask_white_king = 0

        self.bitmask_black_pawn = 0
        self.bitmask_black_knight = 0
        self.bitmask_black_bishop = 0
        self.bitmask_black_rook = 0
        self.bitmask_black_queen = 0
        self.bitmask_black_king = 0

    # Define the load_fen method
    cdef void load_fen_board(self, str fen):
        """
        Load the board part of a FEN string to the Board object.
        """
        cdef int row = 7  # Start from the top row (7) and go to the bottom row (0)
        cdef int col = 0
        cdef char c
        cdef unsigned long long bitmask

        # Reset all bitmasks before loading a new FEN
        self.reset_all_bitmasks()

        for c in fen:
            if c == b'/':
                row -= 1  # Move to the next row down
                col = 0
            elif b'0' <= c <= b'9':  # Check if the character is a digit
                col += int(c) - int('0')
            else:
                bitmask = 1 << (row * 8 + col)
                if c == b'P':
                    print("White pawn at", row, col, "bitmask", bitmask)
                    self.bitmask_white_pawn |= bitmask
                elif c == b'N':
                    self.bitmask_white_knight |= bitmask
                elif c == b'B':
                    self.bitmask_white_bishop |= bitmask
                elif c == b'R':
                    self.bitmask_white_rook |= bitmask
                elif c == b'Q':
                    self.bitmask_white_queen |= bitmask
                elif c == b'K':
                    self.bitmask_white_king |= bitmask
                elif c == b'p':
                    self.bitmask_black_pawn |= bitmask
                elif c == b'n':
                    self.bitmask_black_knight |= bitmask
                elif c == b'b':
                    self.bitmask_black_bishop |= bitmask
                elif c == b'r':
                    self.bitmask_black_rook |= bitmask
                elif c == b'q':
                    self.bitmask_black_queen |= bitmask
                elif c == b'k':
                    self.bitmask_black_king |= bitmask
                col += 1

    # Define the print method
    cpdef void print(self):
        """
        Print 8 lines of 8 characters each, representing the board.
        """
        for i in range(8):
            print("".join([self.get_piece_at(i, j).decode('utf-8') for j in range(8)]))

    # Define the get_piece_at method
    cdef string get_piece_at(self, unsigned long long row, unsigned long long col):
        """
        Get the piece at the given row and column.
        """
        cdef unsigned long long bitmask = 1 << (row * 8 + col)
        if bitmask & self.bitmask_white_pawn:
            return PIECE_NAME_WHITE_PAWN
        elif bitmask & self.bitmask_white_knight:
            return PIECE_NAME_WHITE_KNIGHT
        elif bitmask & self.bitmask_white_bishop:
            return PIECE_NAME_WHITE_BISHOP
        elif bitmask & self.bitmask_white_rook:
            return PIECE_NAME_WHITE_ROOK
        elif bitmask & self.bitmask_white_queen:
            return PIECE_NAME_WHITE_QUEEN
        elif bitmask & self.bitmask_white_king:
            return PIECE_NAME_WHITE_KING
        elif bitmask & self.bitmask_black_pawn:
            return PIECE_NAME_BLACK_PAWN
        elif bitmask & self.bitmask_black_knight:
            return PIECE_NAME_BLACK_KNIGHT
        elif bitmask & self.bitmask_black_bishop:
            return PIECE_NAME_BLACK_BISHOP
        elif bitmask & self.bitmask_black_rook:
            return PIECE_NAME_BLACK_ROOK
        elif bitmask & self.bitmask_black_queen:
            return PIECE_NAME_BLACK_QUEEN
        elif bitmask & self.bitmask_black_king:
            return PIECE_NAME_BLACK_KING
        else:
            return PIECE_NAME_EMPTY_SQUARE
