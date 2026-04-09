import { Response } from 'express';
import { prisma } from '../utils/database';
import { AuthRequest, ApiResponse, CreateOrderRequest, UpdateOrderStatusRequest } from '../types';
import { OrderStatus } from '@prisma/client';

export const getAllOrders = async (req: AuthRequest, res: Response) => {
  try {
    const { status, page = '1', limit = '20' } = req.query;
    const skip = (parseInt(page as string) - 1) * parseInt(limit as string);

    const where: any = {};
    if (status) {
      where.status = status.toUpperCase();
    }

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where,
        include: {
          items: {
            include: {
              product: true,
            },
          },
          user: {
            select: {
              id: true,
              name: true,
              email: true,
              role: true,
            },
          },
        },
        skip,
        take: parseInt(limit as string),
        orderBy: { createdAt: 'desc' },
      }),
      prisma.order.count({ where }),
    ]);

    res.json({
      success: true,
      data: orders,
      pagination: {
        page: parseInt(page as string),
        limit: parseInt(limit as string),
        total,
        pages: Math.ceil(total / parseInt(limit as string)),
      },
    } as ApiResponse);
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get orders',
    } as ApiResponse);
  }
};

export const getOrderById = async (req: AuthRequest, res: Response) => {
  try {
    const order = await prisma.order.findUnique({
      where: { id: req.params.id },
      include: {
        items: {
          include: {
            product: true,
          },
        },
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true,
          },
        },
      },
    });

    if (!order) {
      return res.status(404).json({
        success: false,
        error: 'Order not found',
      } as ApiResponse);
    }

    res.json({
      success: true,
      data: order,
    } as ApiResponse);
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get order',
    } as ApiResponse);
  }
};

export const createOrder = async (req: AuthRequest, res: Response) => {
  try {
    const { customerName, customerPhone, deliveryAddress, deliveryDate, items, notes }: CreateOrderRequest = req.body;

    // Generate order number
    const lastOrder = await prisma.order.findFirst({
      orderBy: { orderNumber: 'desc' },
      select: { orderNumber: true },
    });

    const nextOrderNumber = lastOrder
      ? `ORD-${parseInt(lastOrder.orderNumber.replace('ORD-', '')) + 1}`
      : 'ORD-1001';

    // Calculate total amount
    const products = await prisma.product.findMany({
      where: { id: { in: items.map(item => item.productId) } },
    });

    let totalAmount = 0;
    const orderItems = items.map(item => {
      const product = products.find(p => p.id === item.productId);
      const unitPrice = product?.price || 0;
      const totalPrice = unitPrice * item.quantity;
      totalAmount += totalPrice;

      return {
        productId: item.productId,
        quantity: item.quantity,
        unitPrice,
        totalPrice,
        notes: item.notes,
      };
    });

    const order = await prisma.order.create({
      data: {
        orderNumber: nextOrderNumber,
        customerName,
        customerPhone,
        deliveryAddress,
        deliveryDate: new Date(deliveryDate),
        totalAmount,
        notes,
        userId: req.userId,
        items: {
          create: orderItems,
        },
      },
      include: {
        items: {
          include: {
            product: true,
          },
        },
      },
    });

    res.status(201).json({
      success: true,
      data: order,
    } as ApiResponse);
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create order',
    } as ApiResponse);
  }
};

export const updateOrderStatus = async (req: AuthRequest, res: Response) => {
  try {
    const { status }: UpdateOrderStatusRequest = req.body;

    const order = await prisma.order.update({
      where: { id: req.params.id },
      data: { status: status as OrderStatus },
      include: {
        items: true,
      },
    });

    res.json({
      success: true,
      data: order,
    } as ApiResponse);
  } catch (error) {
    console.error('Update order error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update order',
    } as ApiResponse);
  }
};

export const deleteOrder = async (req: AuthRequest, res: Response) => {
  try {
    await prisma.order.delete({
      where: { id: req.params.id },
    });

    res.json({
      success: true,
      message: 'Order deleted successfully',
    } as ApiResponse);
  } catch (error) {
    console.error('Delete order error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete order',
    } as ApiResponse);
  }
};
