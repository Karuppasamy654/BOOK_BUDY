const mongoose = require('mongoose');

const foodItemSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Food item name is required'],
    trim: true,
    maxlength: [100, 'Food name cannot exceed 100 characters']
  },
  description: {
    type: String,
    maxlength: [500, 'Description cannot exceed 500 characters']
  },
  price: {
    type: Number,
    required: [true, 'Price is required'],
    min: [0, 'Price cannot be negative']
  },
  category: {
    type: String,
    required: [true, 'Category is required'],
    enum: ['breakfast', 'lunch', 'dinner', 'beverages', 'desserts', 'snacks']
  },
  subcategory: {
    type: String,
    enum: ['veg', 'non-veg', 'vegan', 'jain', 'continental', 'indian', 'chinese', 'italian', 'mexican']
  },
  images: [{
    url: String,
    alt: String,
    isPrimary: { type: Boolean, default: false }
  }],
  ingredients: [String],
  allergens: [String],
  nutritionalInfo: {
    calories: Number,
    protein: Number,
    carbs: Number,
    fat: Number,
    fiber: Number
  },
  preparationTime: {
    type: Number, // in minutes
    default: 15
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  isPopular: {
    type: Boolean,
    default: false
  },
  isSpicy: {
    type: Boolean,
    default: false
  },
  spiceLevel: {
    type: Number,
    min: 0,
    max: 5,
    default: 0
  },
  tags: [String],
  hotel: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Hotel',
    required: true
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  ratings: [{
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    rating: {
      type: Number,
      min: 1,
      max: 5
    },
    review: String,
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  averageRating: {
    type: Number,
    default: 0
  },
  totalOrders: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

foodItemSchema.virtual('primaryImage').get(function() {
  const primary = this.images.find(img => img.isPrimary);
  return primary ? primary.url : (this.images[0] ? this.images[0].url : null);
});

foodItemSchema.virtual('ratingCount').get(function() {
  return this.ratings.length;
});

foodItemSchema.methods.addRating = function(userId, rating, review = '') {
  this.ratings = this.ratings.filter(r => !r.user.equals(userId));
  
  this.ratings.push({
    user: userId,
    rating,
    review
  });
  
  this.averageRating = this.ratings.reduce((sum, r) => sum + r.rating, 0) / this.ratings.length;
  
  return this.save();
};

foodItemSchema.methods.updateAvailability = function(isAvailable) {
  this.isAvailable = isAvailable;
  return this.save();
};

foodItemSchema.methods.updatePrice = function(newPrice) {
  this.price = newPrice;
  return this.save();
};

foodItemSchema.statics.getPopularItems = function(limit = 10) {
  return this.find({ isPopular: true, isAvailable: true })
    .sort({ totalOrders: -1, averageRating: -1 })
    .limit(limit)
    .populate('hotel', 'name location');
};

foodItemSchema.statics.searchItems = function(query, filters = {}) {
  const searchQuery = {
    $or: [
      { name: { $regex: query, $options: 'i' } },
      { description: { $regex: query, $options: 'i' } },
      { ingredients: { $in: [new RegExp(query, 'i')] } },
      { tags: { $in: [new RegExp(query, 'i')] } }
    ],
    isAvailable: true,
    ...filters
  };
  
  return this.find(searchQuery)
    .sort({ averageRating: -1, totalOrders: -1 })
    .populate('hotel', 'name location');
};

foodItemSchema.index({ name: 'text', description: 'text', ingredients: 'text', tags: 'text' });
foodItemSchema.index({ category: 1 });
foodItemSchema.index({ subcategory: 1 });
foodItemSchema.index({ hotel: 1 });
foodItemSchema.index({ isAvailable: 1 });
foodItemSchema.index({ isPopular: 1 });
foodItemSchema.index({ averageRating: -1 });
foodItemSchema.index({ totalOrders: -1 });
foodItemSchema.index({ price: 1 });
foodItemSchema.index({ createdAt: -1 });

module.exports = mongoose.model('FoodItem', foodItemSchema);
