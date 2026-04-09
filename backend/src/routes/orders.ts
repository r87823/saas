import { Router } from 'express';
import * as ordersController from '../controllers/orders';
import { authMiddleware, requireRole } from '../middleware/auth';

const router = Router();

router.get('/', authMiddleware, ordersController.getAllOrders);
router.get('/:id', authMiddleware, ordersController.getOrderById);
router.post('/', authMiddleware, ordersController.createOrder);
router.patch('/:id/status', authMiddleware, requireRole('ADMIN', 'MANAGER'), ordersController.updateOrderStatus);
router.delete('/:id', authMiddleware, requireRole('ADMIN', 'MANAGER'), ordersController.deleteOrder);

export default router;
