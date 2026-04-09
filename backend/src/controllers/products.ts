import { Response } from 'express';
import { prisma } from '../utils/database';
import { AuthRequest, ApiResponse, CreateProductRequest } from '../types';

export const getAllProducts = async (req: AuthRequest, res: Response) => {
  try {
    const { category, page = '1', limit = '20', search } = req.query;
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const where: any = { isActive: true };
    if (category) {
      where.categoryId = category;
    }
    if (search) {
      where.OR = [
        { name: { contains: search as string, mode: 'insensitive' } },
        { nameAr: { contains: search as string, mode: 'insensitive' } },
      ];
    }

    const [products, total] = await Promise.all([
      prisma.product.findMany({
        where,
        include: { category: true },
        skip,
        take: parseInt(limit as string),
        orderBy: { createdAt: 'desc' },
      }),
      prisma.product.count({ where }),
    ]);

    res.json({
      success: true,
      data: products,
      pagination: {
        page: parseInt(page as string),
        limit: parseInt(limit as string),
        total,
        pages: Math.ceil(total / parseInt(limit as string)),
      },
    } as ApiResponse);
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get products',
    } as ApiResponse);
  }
};

export const getProductById = async (req: AuthRequest, res: Response) => {
  try {
    const product = await prisma.product.findUnique({
      where: { id: req.params.id },
      include: { category: true },
    });

    if (!product) {
      return res.status(404).json({
        success: false,
        error: 'Product not found',
      } as ApiResponse);
    }

    res.json({
      success: true,
      data: product,
    } as ApiResponse);
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get product',
    } as ApiResponse);
  }
};

export const createProduct = async (req: AuthRequest, res: Response) => {
  try {
    const { name, nameAr, price, costPrice, categoryId, description, image, prepTime, stock }: CreateProductRequest = req.body;

    const product = await prisma.product.create({
      data: {
        name,
        nameAr,
        price: parseFloat(price),
        costPrice: costPrice ? parseFloat(costPrice) : null,
        categoryId,
        description,
        image,
        prepTime: prepTime || 1,
        stock: stock || 0,
      },
      include: { category: true },
    });

    res.status(201).json({
      success: true,
      data: product,
    } as ApiResponse);
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create product',
    } as ApiResponse);
  }
};

export const updateProduct = async (req: AuthRequest, res: Response) => {
  try {
    const { name, nameAr, price, costPrice, categoryId, description, image, prepTime, stock }: CreateProductRequest = req.body;

    const product = await prisma.product.update({
      where: { id: req.params.id },
      data: {
        name,
        nameAr,
        price: price ? parseFloat(price) : undefined,
        costPrice: costPrice ? parseFloat(costPrice) : undefined,
        categoryId,
        description,
        image,
        prepTime: prepTime || 1,
        stock,
      },
      include: { category: true },
    });

    res.json({
      success: true,
      data: product,
    } as ApiResponse);
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update product',
    } as ApiResponse);
  }
};

export const deleteProduct = async (req: AuthRequest, res: Response) => {
  try {
    await prisma.product.delete({
      where: { id: req.params.id },
    });

    res.json({
      success: true,
      message: 'Product deleted successfully',
    } as ApiResponse);
  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete product',
    } as ApiResponse);
  }
};
