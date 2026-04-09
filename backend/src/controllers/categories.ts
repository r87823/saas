import { Response } from 'express';
import { prisma } from '../utils/database';
import { AuthRequest, ApiResponse, CreateCategoryRequest } from '../types';

export const getAllCategories = async (req: AuthRequest, res: Response) => {
  try {
    const categories = await prisma.category.findMany({
      where: { isActive: true },
      include: {
        _count: {
          select: { products: true },
        },
      },
      orderBy: { name: 'asc' },
    });

    res.json({
      success: true,
      data: categories,
    } as ApiResponse);
  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get categories',
    } as ApiResponse);
  }
};

export const getCategoryById = async (req: AuthRequest, res: Response) => {
  try {
    const category = await prisma.category.findUnique({
      where: { id: req.params.id },
      include: {
        products: {
          where: { isActive: true },
        },
      },
    });

    if (!category) {
      return res.status(404).json({
        success: false,
        error: 'Category not found',
      } as ApiResponse);
    }

    res.json({
      success: true,
      data: category,
    } as ApiResponse);
  } catch (error) {
    console.error('Get category error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get category',
    } as ApiResponse);
  }
};

export const createCategory = async (req: AuthRequest, res: Response) => {
  try {
    const { name, nameAr, description }: CreateCategoryRequest = req.body;

    const category = await prisma.category.create({
      data: {
        name,
        nameAr,
        description,
      },
    });

    res.status(201).json({
      success: true,
      data: category,
    } as ApiResponse);
  } catch (error) {
    console.error('Create category error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create category',
    } as ApiResponse);
  }
};

export const updateCategory = async (req: AuthRequest, res: Response) => {
  try {
    const { name, nameAr, description }: CreateCategoryRequest = req.body;

    const category = await prisma.category.update({
      where: { id: req.params.id },
      data: {
        name,
        nameAr,
        description,
      },
    });

    res.json({
      success: true,
      data: category,
    } as ApiResponse);
  } catch (error) {
    console.error('Update category error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update category',
    } as ApiResponse);
  }
};

export const deleteCategory = async (req: AuthRequest, res: Response) => {
  try {
    await prisma.category.delete({
      where: { id: req.params.id },
    });

    res.json({
      success: true,
      message: 'Category deleted successfully',
    } as ApiResponse);
  } catch (error) {
    console.error('Delete category error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete category',
    } as ApiResponse);
  }
};
