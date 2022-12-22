namespace Day12 {
    struct Coordinate {
        public int X { get; set; }
        public int Y { get; set; }

        public Coordinate(int x, int y) {
            X = x;
            Y = y;
        }

        public Coordinate Move(Action action) {
            switch (action) {
                case Action.Up:
                    return new Coordinate(X, Y - 1);
                case Action.Down:
                    return new Coordinate(X, Y + 1);
                case Action.Left:
                    return new Coordinate(X - 1, Y);
                case Action.Right:
                    return new Coordinate(X + 1, Y);
                default:
                    throw new ArgumentException("Invalid action");
            }
        }

        // Manhattan distance to another coordinate
        public int DistanceTo(Coordinate other) {
            return Math.Abs(X - other.X) + Math.Abs(Y - other.Y);
        }
    }

    class Node {
        public Coordinate Coordinate { get; private set; }
        public Node Parent { get; private set; }
        public int Cost { get; private set; }

        public Node(Coordinate coordinate, Node parent, int cost) {
            Coordinate = coordinate;
            Parent = parent;
            Cost = cost;
        }

        public IEnumerable<Node> Path() {
            var node = this;
            while (node != null) {
                yield return node;
                node = node.Parent;
            }
        }
    }
    enum Action {
        Up,
        Down,
        Left,
        Right
    }

    class Grid {
        private char[,] grid;
        public Coordinate OriginCoordinate { get; set; }
        public Coordinate GoalCoordinate { get; private set; }

        public Grid(string[] lines) {
            grid = new char[lines[0].Length, lines.Length];
            for (int y = 0; y < lines.Length; y++) {
                for (int x = 0; x < lines[y].Length; x++) {
                    grid[x, y] = lines[y][x];
                    if (grid[x, y] == 'S') {
                        // Origin coordinate has value a
                        grid[x, y] = 'a';
                        OriginCoordinate = new Coordinate(x, y);
                    } else if (grid[x, y] == 'E') {
                        // Goal coordinate has value z
                        grid[x, y] = 'z';
                        GoalCoordinate = new Coordinate(x, y);
                    }
                }
            }
        }

        public char ValueAt(Coordinate coordinate) {
            return grid[coordinate.X, coordinate.Y];
        }

        public bool InBounds(Coordinate coordinate) {
            return coordinate.X >= 0 && coordinate.X < grid.GetLength(0) && coordinate.Y >= 0 && coordinate.Y < grid.GetLength(1);
        }

        public IEnumerable<Coordinate> CoordinatesWithValue(char c) {
            for (int y = 0; y < grid.GetLength(1); y++) {
                for (int x = 0; x < grid.GetLength(0); x++) {
                    if (grid[x, y] == c) {
                        yield return new Coordinate(x, y);
                    }
                }
            }
        }

        public IEnumerable<Coordinate> CoordinatesReachableFrom(Coordinate coordinate) {
            // If already at goal, no need to move
            if (coordinate.X == GoalCoordinate.X && coordinate.Y == GoalCoordinate.Y) {
                return new Coordinate[] { };
            }
            var coordinateValue = ValueAt(coordinate);
            return Enum.GetValues(typeof(Action))
            .Cast<Action>()
            .Select(action => coordinate.Move(action))
            .Where(newCoordinate => InBounds(newCoordinate))
            .Where(newCoordinate => {
                var newValue = ValueAt(newCoordinate);
                var elevationIncrease = newValue - coordinateValue;
                return elevationIncrease <= 1 || newValue == 'E';
            });
        }

        public void Print() {
            for (int y = 0; y < grid.GetLength(1); y++) {
                for (int x = 0; x < grid.GetLength(0); x++) {
                    Console.Write(grid[x, y]);
                }
                Console.WriteLine();
            }
        }
    }

    class Solution {

        private static Node? Solve(Grid grid, int? maxCost = null) {
            var startNode = new Node(grid.OriginCoordinate, null, 0);
            var queue = new PriorityQueue<Node, int>();
            queue.Enqueue(startNode, 0);
            var visited = new Dictionary<Coordinate, Node>();
            while (queue.Count > 0) {
                // If the priority of the next node is higher than the max cost, stop
                if (maxCost != null && queue.TryPeek(out var _, out var nextCost) && nextCost > maxCost) {
                    break;
                }
                var node = queue.Dequeue();
                var children = Expand(grid, node);
                foreach (var child in children) {
                    if (child.Coordinate.Equals(grid.GoalCoordinate)) {
                        return child;
                    }
                    // Check if already visited
                    if (visited.TryGetValue(child.Coordinate, out var visitedNode)) {
                        // If visited node has lower cost than current node, skip
                        if (visitedNode.Cost <= child.Cost) {
                            continue;
                        }
                    }
                    visited[child.Coordinate] = child;
                    queue.Enqueue(child, child.Cost);
                }
            }
            return null;
        }

        private static IEnumerable<Node> Expand(Grid grid, Node node) {
            // Get reachable coordinates from current node
            var reachableCoordinates = grid.CoordinatesReachableFrom(node.Coordinate);
            foreach(var coordinate in reachableCoordinates) {
                yield return new Node(coordinate, node, node.Cost + 1);
            }
        }
        public static void Main(string[] args) {
            var lines = File.ReadAllLines(args[0]);
            var grid = new Grid(lines);
            
            var solution = Solve(grid);
            if (solution == null) {
                Console.WriteLine("No solution found");
                return;
            }
            Console.WriteLine($"Solution found in {solution.Cost} steps");

            // Part 2
            // Any cell with value 'a' is a valid start point
            var startPoints = grid.CoordinatesWithValue('a');
            int? minimumCost = null;
            foreach (var startPoint in startPoints) {
                grid.OriginCoordinate = startPoint;
                solution = Solve(grid, minimumCost);
                if (solution != null) {
                    Console.WriteLine($"Solution found in {solution.Cost} steps");
                    if (minimumCost == null || solution.Cost < minimumCost) {
                        minimumCost = solution.Cost;
                    }
                }
            }
            Console.WriteLine($"Minimum cost: {minimumCost}");
        }
    }
}