<meta name='viewport' content='width=device-width, initial-scale=1'/><!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>لعبة X-O</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: linear-gradient(135deg, #1e2937, #0f172a);
            font-family: Arial, sans-serif;
            height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            color: white;
        }
        h1 { color: #60a5fa; font-size: 2.8rem; margin-bottom: 8px; }
        
        .difficulty {
            margin: 15px 0 20px 0;
            text-align: center;
        }
        .difficulty label {
            font-size: 1.25rem;
            display: block;
            margin-bottom: 8px;
        }
        input[type="range"] {
            width: 300px;
            accent-color: #f59e0b;
        }
        .level {
            font-size: 1.5rem;
            font-weight: bold;
            color: #fbbf24;
        }

        .status {
            font-size: 1.55rem;
            margin: 15px 0;
            min-height: 55px;
        }
        .board {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 12px;
            background: #1e2937;
            padding: 15px;
            border-radius: 20px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.6);
        }
        .cell {
            width: 105px;
            height: 105px;
            background: #334155;
            border-radius: 16px;
            font-size: 3.8rem;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: 0.2s;
        }
        .cell:hover { background: #475569; }
        .cell.x { color: #f87171; }
        .cell.o { color: #60a5fa; }

        button {
            margin-top: 25px;
            padding: 14px 45px;
            font-size: 1.4rem;
            background: #22c55e;
            color: white;
            border: none;
            border-radius: 50px;
        }
    </style>
</head>
<body>

    <h1>⭕ X - O ⭕</h1>
    
    <div class="difficulty">
        <label>مستوى الذكاء الاصطناعي: <span id="levelText" class="level">5</span></label>
        <input type="range" id="difficulty" min="1" max="10" value="5">
    </div>

    <div class="status" id="status">دورك.. العب بـ X</div>
    
    <div class="board" id="board"></div>
    
    <button onclick="resetGame()">لعبة جديدة</button>

<script>
let board = Array(9).fill(null);
let currentPlayer = 'X';
let gameActive = true;
let difficulty = 5;

const statusDisplay = document.getElementById('status');
const boardElement = document.getElementById('board');
const difficultySlider = document.getElementById('difficulty');
const levelText = document.getElementById('levelText');

difficultySlider.addEventListener('input', () => {
    difficulty = parseInt(difficultySlider.value);
    levelText.textContent = difficulty;
});

function createBoard() {
    boardElement.innerHTML = '';
    for (let i = 0; i < 9; i++) {
        const cell = document.createElement('div');
        cell.classList.add('cell');
        cell.dataset.index = i;
        cell.addEventListener('click', handleCellClick);
        boardElement.appendChild(cell);
    }
}

function handleCellClick(e) {
    const index = parseInt(e.target.dataset.index);
    if (board[index] || !gameActive || currentPlayer === 'O') return;

    makeMove(index, 'X');

    if (gameActive) {
        setTimeout(aiMove, 450);
    }
}

function makeMove(index, player) {
    board[index] = player;
    const cells = document.querySelectorAll('.cell');
    cells[index].textContent = player;
    cells[index].classList.add(player.toLowerCase());

    const win = checkWin(player);
    if (win) {
        gameActive = false;
        statusDisplay.textContent = player === 'X' ? '🎉 مبروك! أنت فزت!' : '😔 الذكاء الاصطناعي فاز';
        highlightWinningCells(win);
        return;
    }

    if (board.every(c => c !== null)) {
        gameActive = false;
        statusDisplay.textContent = 'تعادل!';
        return;
    }

    currentPlayer = player === 'X' ? 'O' : 'X';
    statusDisplay.textContent = currentPlayer === 'O' ? 'دور الـ AI...' : 'دورك.. العب بـ X';
}

// ==================== الذكاء الاصطناعي المحسن ====================
function aiMove() {
    if (!gameActive) return;

    let bestMove = null;
    let bestScore = -Infinity;

    // في المستويات المنخفضة، نعطي فرصة للـ AI يغلط
    const errorChance = Math.max(0, 10 - difficulty) * 8; // كل ما المستوى منخفض = احتمال الغلط أعلى

    if (Math.random() * 100 < errorChance && difficulty <= 6) {
        // يختار حركة عشوائية (يغلط)
        const available = board.map((v, i) => v === null ? i : null).filter(v => v !== null);
        bestMove = available[Math.floor(Math.random() * available.length)];
    } else {
        // يلعب بذكاء
        for (let i = 0; i < 9; i++) {
            if (!board[i]) {
                board[i] = 'O';
                let score = minimax(board, 0, false, difficulty);
                board[i] = null;
                if (score > bestScore) {
                    bestScore = score;
                    bestMove = i;
                }
            }
        }
    }

    if (bestMove !== null) {
        makeMove(bestMove, 'O');
    }
}

function minimax(newBoard, depth, isMaximizing, diff) {
    const maxDepth = Math.floor(diff / 3) + 4; // المستوى 10 = عمق أكبر

    if (depth >= maxDepth) return 0;

    const winner = checkWinSimple(newBoard);
    if (winner === 'O') return 20 - depth;
    if (winner === 'X') return depth - 20;
    if (newBoard.every(cell => cell !== null)) return 0;

    if (isMaximizing) {
        let best = -Infinity;
        for (let i = 0; i < 9; i++) {
            if (!newBoard[i]) {
                newBoard[i] = 'O';
                best = Math.max(best, minimax(newBoard, depth + 1, false, diff));
                newBoard[i] = null;
            }
        }
        return best;
    } else {
        let best = Infinity;
        for (let i = 0; i < 9; i++) {
            if (!newBoard[i]) {
                newBoard[i] = 'X';
                best = Math.min(best, minimax(newBoard, depth + 1, true, diff));
                newBoard[i] = null;
            }
        }
        return best;
    }
}

function checkWin(player) {
    const wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (let cond of wins) {
        if (cond.every(i => board[i] === player)) return cond;
    }
    return null;
}

function checkWinSimple(newBoard) {
    const wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
    for (let cond of wins) {
        if (cond.every(i => newBoard[i] === 'O')) return 'O';
        if (cond.every(i => newBoard[i] === 'X')) return 'X';
    }
    return null;
}

function highlightWinningCells(cond) {
    const cells = document.querySelectorAll('.cell');
    cond.forEach(i => {
        cells[i].style.background = '#22c55e';
        cells[i].style.color = '#fff';
    });
}

function resetGame() {
    board = Array(9).fill(null);
    currentPlayer = 'X';
    gameActive = true;
    statusDisplay.textContent = 'دورك.. العب بـ X';
    createBoard();
}

// بداية اللعبة
createBoard();
</script>

</body>
</html>
