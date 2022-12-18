namespace Day9
{
    enum Direction
    {
        Up,
        Down,
        Left,
        Right
    }

    struct Move {
        public Direction Direction { get; set; }
        public int Distance { get; set; }

        public override string ToString()
        {
            return $"{Direction} {Distance}";
        }
        public static Move Parse(string input)
        {
            // Split string by space
            var split = input.Split(' ');
            var direction = split[0] switch {
                "U" => Direction.Up,
                "D" => Direction.Down,
                "L" => Direction.Left,
                "R" => Direction.Right,
                _ => throw new ArgumentException("Invalid direction")
            };
            var distance = int.Parse(split[1]);
            return new Move { Direction = direction, Distance = distance };
        }
    }
    struct Coordinate
    {
        public int X { get; set; }
        public int Y { get; set; }

        public int HorizontalDistanceTo(Coordinate other)
        {
            return other.X - X;
        }

        public int VerticalDistanceTo(Coordinate other)
        {
            return other.Y - Y;
        }

        public bool IsAdjacentTo(Coordinate other)
        {
            return Math.Abs(HorizontalDistanceTo(other)) <= 1 && Math.Abs(VerticalDistanceTo(other)) <= 1;
        }

        public override string ToString()
        {
            return $"({X}, {Y})";
        }

    }
    class RopeEnd
    {
        protected Coordinate _currentPosition;
        public Coordinate CurrentPosition => _currentPosition;
        private List<Coordinate> PreviousPositions { get; }

        public RopeEnd(int x, int y)
        {
            _currentPosition = new Coordinate { X = x, Y = y };
            PreviousPositions = new List<Coordinate> { _currentPosition };
        }

        public void Move(int dx, int dy)
        {
            MoveTo(_currentPosition.X + dx, _currentPosition.Y + dy);
        }

        public void Move(Direction direction)
        {
            switch (direction)
            {
                case Direction.Up:
                    Move(0, -1);
                    break;
                case Direction.Down:
                    Move(0, 1);
                    break;
                case Direction.Left:
                    Move(-1, 0);
                    break;
                case Direction.Right:
                    Move(1, 0);
                    break;
            }
        }

        public void MoveTo(int x, int y)
        {
            _currentPosition = new Coordinate { X = x, Y = y };
            PreviousPositions.Add(_currentPosition);
        }

        public int UniquePositionsVisited()
        {
            return PreviousPositions.Distinct().Count();
        }
    }

    class Tail : RopeEnd
    {
        public Tail(int x, int y) : base(x, y)
        {
        }
        public void ChaseHead(RopeEnd head)
        {
            var horizontalDistance = _currentPosition.HorizontalDistanceTo(head.CurrentPosition);
            var verticalDistance = _currentPosition.VerticalDistanceTo(head.CurrentPosition);
            if (horizontalDistance == 0 && Math.Abs(verticalDistance) == 2)
            {
                // Move one space towards head
                MoveTo(_currentPosition.X, _currentPosition.Y + (verticalDistance / 2));
                return;
            }
            if (verticalDistance == 0 && Math.Abs(horizontalDistance) == 2)
            {
                // Move one space towards head
                MoveTo(_currentPosition.X + (horizontalDistance / 2), _currentPosition.Y);
                return;
            }
            // If in a different row or column, move 1 diagonally towards head
            if (!head.CurrentPosition.IsAdjacentTo(_currentPosition)){
                MoveTo(_currentPosition.X + Math.Sign(horizontalDistance), _currentPosition.Y + Math.Sign(verticalDistance));
            }
        }
    }

    class Program
    {
        private const int OriginX = 0;
        private const int OriginY = 4;
        static void Main(string[] args)
        {
            var moves = File.ReadAllLines(args[0]).Select(line => Move.Parse(line)).ToList();
            var head = new RopeEnd(OriginX, OriginY);
            var tail = new Tail(OriginX, OriginY);

            foreach(var move in moves) {
                // Apply each move and chase sequentially
                for(var i = 0; i < move.Distance; i++) {
                    head.Move(move.Direction);
                    tail.ChaseHead(head);
                }
            }
            // Get number of unique positions visited by tail
            Console.WriteLine(tail.UniquePositionsVisited());
        }
    }
}
