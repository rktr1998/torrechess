import chess
import random
import json

def get_random_chess960_start_board() -> chess.Board:
    board:chess.Board = chess.Board.from_chess960_pos(random.randint(0, 959))
    return board

def play_random_chess960_games(n_games:int=1) -> list[chess.Board]:
    boards:list[chess.Board] = []
    for _ in range(n_games):
        board = get_random_chess960_start_board()
        while not board.is_game_over():
            move = random.choice(list(board.legal_moves))
            board.push(move)
        boards.append(board)
    return boards

def generate_legal_moves_dataset(n_games: int) -> list[dict]:
    boards = play_random_chess960_games(n_games)
    dataset = []
    # Iterate over all games played
    for board in boards:
        # Iterate over all moves played in a game with board.pop() until move stack is empty
        while board.move_stack:
            move = board.pop()
            legal_moves = [move.uci() for move in board.legal_moves]
            dataset.append({"fen": board.fen(), "legal_moves": legal_moves})
    return dataset    

def save_dataset_to_json(dataset:dict[str, list[str]], filename:str) -> None:
    with open(filename, "w") as f:
        json.dump(dataset, f)
    return None

################################################################################

if __name__ == "__main__":
    n_games = 10000
    dataset = generate_legal_moves_dataset(n_games)
    save_dataset_to_json(dataset, f"legal_moves_dataset_{len(dataset)}.json")
    print("Dataset saved to json file.")
