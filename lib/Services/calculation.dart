
String getPercentage(num amount, num mrp)  {

  var discountPercent = 100 - (amount / mrp) * 100;

  return discountPercent.toStringAsFixed(0);
}

double getAvgRating(List<num> ratings) {
  if (ratings.isEmpty) {
    return 0.0; // No ratings to calculate an average, return 0.
  }

  num sum = 0;
  int validRatingsCount = 0; // Track the count of valid ratings.

  for (num rating in ratings) {
    if (rating >= 1 && rating <= 5) {
      sum += rating;
      validRatingsCount++;
    } else {
      // Handle invalid ratings here, if needed.
    }
  }

  if (validRatingsCount == 0) {
    return 0.0; // No valid ratings, return 0.
  }

  return sum / validRatingsCount;
}