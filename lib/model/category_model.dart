class CategoryModel {
  int? categoryId;
  String? category;

  CategoryModel({this.categoryId, this.category});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['category_id'] = categoryId;
    data['category'] = category;
    return data;
  }
}
