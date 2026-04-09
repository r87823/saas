export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface RegisterRequest {
  email: string;
  password: string;
  name?: string;
  phone?: string;
  role?: string;
}

export interface CreateOrderRequest {
  customerName: string;
  customerPhone: string;
  deliveryAddress: string;
  deliveryDate: Date;
  items: {
    productId: string;
    quantity: number;
    notes?: string;
  }[];
  notes?: string;
}

export interface UpdateOrderStatusRequest {
  status: string;
}

export interface CreateProductRequest {
  name: string;
  nameAr: string;
  price: number;
  costPrice?: number;
  categoryId: string;
  description?: string;
  image?: string;
  prepTime?: number;
  stock?: number;
}

export interface CreateCategoryRequest {
  name: string;
  nameAr: string;
  description?: string;
}
