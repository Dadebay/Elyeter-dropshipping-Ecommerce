import '../../../../core/network/api_response.dart';

/// One page from `GET /products/:id/reviews`, including the rating summary.
class ProductReviews {
  const ProductReviews({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.summary,
    this.myReview,
  });

  factory ProductReviews.fromJson(Map<String, dynamic> json) => ProductReviews(
    items: json.listOf('items').map(ProductReviewEntry.fromJson).toList(),
    totalCount: json.intVal('totalCount'),
    page: json.intVal('page', 1),
    summary: ProductReviewSummary.fromJson(json.mapOrNull('summary') ?? {}),
    myReview: switch (json.mapOrNull('my_review')) {
      final Map<String, dynamic> value => ProductReviewEntry.fromJson(value),
      _ => null,
    },
  );

  final List<ProductReviewEntry> items;
  final int totalCount;
  final int page;
  final ProductReviewSummary summary;
  final ProductReviewEntry? myReview;
}

class ProductReviewSummary {
  const ProductReviewSummary({
    required this.average,
    required this.count,
    required this.distribution,
  });

  factory ProductReviewSummary.fromJson(Map<String, dynamic> json) {
    final counts = json.mapOrNull('distribution') ?? {};
    return ProductReviewSummary(
      average: json.doubleOrNull('average'),
      count: json.intVal('count'),
      distribution: {
        for (var stars = 1; stars <= 5; stars++)
          stars: (counts['$stars'] as num?)?.toInt() ?? 0,
      },
    );
  }

  final double? average;
  final int count;
  final Map<int, int> distribution;

  /// Relative bar lengths, ordered from five stars down to one.
  List<double> get shares => [
    for (var stars = 5; stars >= 1; stars--)
      count == 0 ? 0 : (distribution[stars] ?? 0) / count,
  ];
}

class ProductReviewImage {
  const ProductReviewImage({required this.objectName, required this.url});

  factory ProductReviewImage.fromJson(Map<String, dynamic> json) =>
      ProductReviewImage(
        objectName: json.strOrNull('object_name') ?? '',
        url: json.strOrNull('url') ?? '',
      );

  /// Sent back when saving an edited review; [url] is what gets drawn.
  final String objectName;
  final String url;
}

/// The "Sort by" choices; photo options filter rather than sort.
enum ReviewSortOption {
  newest,
  oldest,
  mostLiked,
  mostDisliked,
  withPhotos,
  withoutPhotos;

  String? get sortParam => switch (this) {
    newest || withPhotos || withoutPhotos => null,
    oldest => 'oldest',
    mostLiked => 'most_liked',
    mostDisliked => 'most_disliked',
  };

  bool? get hasImages => switch (this) {
    withPhotos => true,
    withoutPhotos => false,
    _ => null,
  };
}

/// "Helpful" counters returned by the reaction endpoints.
class ReviewReactionResult {
  const ReviewReactionResult({
    required this.likesCount,
    required this.dislikesCount,
    this.myReaction,
  });

  factory ReviewReactionResult.fromJson(Map<String, dynamic> json) =>
      ReviewReactionResult(
        likesCount: json.intVal('likes_count'),
        dislikesCount: json.intVal('dislikes_count'),
        myReaction: json.strOrNull('my_reaction'),
      );

  final int likesCount;
  final int dislikesCount;
  final String? myReaction;
}

class ProductReviewEntry {
  const ProductReviewEntry({
    required this.id,
    required this.rating,
    this.comment,
    this.author,
    this.createdAt,
    this.isMine = false,
    this.images = const [],
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.myReaction,
    this.isHidden = false,
  });

  factory ProductReviewEntry.fromJson(Map<String, dynamic> json) {
    final user = json.mapOrNull('user');
    return ProductReviewEntry(
      id: json.intVal('id'),
      rating: json.intVal('rating'),
      comment: json.strOrNull('comment'),
      author:
          json.strOrNull('author') ??
          json.strOrNull('username') ??
          user?.strOrNull('username') ??
          user?.strOrNull('name') ??
          user?.strOrNull('full_name') ??
          _fullName(user) ??
          json.strOrNull('name'),
      createdAt: json.dateOrNull('created_at'),
      isMine: json.boolVal('is_mine'),
      images: json.listOf('images').map(ProductReviewImage.fromJson).toList(),
      likesCount: json.intVal('likes_count'),
      dislikesCount: json.intVal('dislikes_count'),
      myReaction: json.strOrNull('my_reaction'),
      isHidden: json.boolVal('is_hidden'),
    );
  }

  static String? _fullName(Map<String, dynamic>? user) {
    final name = [
      user?.strOrNull('first_name'),
      user?.strOrNull('last_name'),
    ].whereType<String>().join(' ');
    return name.isEmpty ? null : name;
  }

  ProductReviewEntry withReaction(ReviewReactionResult reaction) =>
      ProductReviewEntry(
        id: id,
        rating: rating,
        comment: comment,
        author: author,
        createdAt: createdAt,
        isMine: isMine,
        images: images,
        likesCount: reaction.likesCount,
        dislikesCount: reaction.dislikesCount,
        myReaction: reaction.myReaction,
        isHidden: isHidden,
      );

  final int id;
  final int rating;
  final String? comment;
  final String? author;
  final DateTime? createdAt;
  final bool isMine;
  final List<ProductReviewImage> images;
  final int likesCount;
  final int dislikesCount;
  final String? myReaction;
  final bool isHidden;
}
