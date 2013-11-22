

class Cell {

	private boolean default_state;
	private boolean next_state;
	private boolean alive;

	ArrayList<Cell> neighbors;

	Cell(boolean default_state) {
		this.default_state = default_state;
		this.alive = default_state;

		neighbors = new ArrayList<Cell>();
	}

	void setNextState(boolean next) {
		this.next_state = next;
	}

	void transitionState() {
		this.alive = next_state;
	}

	boolean getState() {
		return this.alive;
	}

	void setState(boolean val) {
		this.alive = val;
	}


	void addNeighbor(Cell cell) {
		this.neighbors.add(cell);
	}

	void invertState() {
		this.alive = !this.alive;
	}

	int countNeighbors() {
		int count = 0;
		for (int i = 0; i < neighbors.size(); i++) {
			if (neighbors.get(i).alive) {
				count++;
			}
		}
		return count;
	}

}

class CellGrid {

	private Cell[][] grid;
	int xsize;
	int ysize;

	CellGrid(int x, int y, boolean default_state) {
		this.xsize = x;
		this.ysize = y;

		grid = new Cell[x][y];


		for (int i = 0; i < x; i++) {
			for (int j = 0; j < y; j++) {
				grid[i][j] = new Cell(default_state);
			}
		}

		for (int i = 0; i < x; i++) {
			for (int j = 0; j < y; j++) {
				initializeNeigborLinks(i, j, grid[i][j]);
			}
		}

	}

	Cell getCell(int x, int y) {

		if (x >= 0 && x < xsize && y >= 0 && y < ysize) {
			return grid[x][y];
		} else {
			return null;
		}

	}

	void initializeNeigborLinks(int x, int y, Cell cell) {

		for (int i = -1; i <= 1; i++) {
			for (int j = -1; j <= 1; j++) {

				if (!(i == 0 && j == 0)) {
					int nx = x + i;
					int ny = y + j;

					Cell neighbor = getCell(nx, ny);
					if (neighbor != null) {
						cell.addNeighbor(neighbor);
					}
				}
			}

		}

	}

}


class Life {

	CellGrid cells;

	int tick = 0;

	Life(int x, int y) {
		this.cells = new CellGrid(x, y, false);
	}

	void turnOn(int x, int y) {
		this.cells.getCell(x, y).setState(true);
	}

	void updateFrame() {
		tick++;

		for (int x = 0; x < cells.xsize; x++) {
			for (int y = 0; y < cells.ysize; y++) {

				Cell cell = cells.getCell(x, y);

				int neighbor_count = cell.countNeighbors();

				if (birthCondition(neighbor_count)) {
					cell.setNextState(true);
				} else if (deathCondition(neighbor_count)) {
					cell.setNextState(false);
				} else if (stasisCondition(neighbor_count)) {
					cell.setNextState(cell.getState());
				}
			}
		}

		for (int x = 0; x < cells.xsize; x++) {
			for (int y = 0; y < cells.ysize; y++) {
				Cell cell = cells.getCell(x, y);
				cell.transitionState();
			}
		}
	}


	boolean birthCondition(int neighbor_count) {
		return neighbor_count == 3;
	}

	boolean deathCondition(int neighbor_count) {
		return neighbor_count <=1 || neighbor_count >= 4;
	}

	boolean stasisCondition(int neighbor_count) {
		return neighbor_count == 3 || neighbor_count == 2;
	}


}



