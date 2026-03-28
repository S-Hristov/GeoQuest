int levelForPoints(int points) => 1 + (points ~/ 250);

int nextLevelPointsForPoints(int points) => levelForPoints(points) * 250;
