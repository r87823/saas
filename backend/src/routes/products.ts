import { Router } from 'express';
import * as productsController from '../controllers/products';
import { authMiddleware, requireRole } from '../middleware/auth';

const router = Router();

router.get('/', authMiddleware, productsController.getAllProducts);
router.get('/:id', authMiddleware, productsController.getProductById);
router.post('/', authMiddleware, requireRole('ADMIN', 'MANAGER'), productsController.createProduct);
router.put('/:id', authMiddleware, requireRole('ADMIN', 'MANAGER'), productsController.updateProduct);
router.delete('/:id', authMiddleware, requireRole('ADMIN', 'MANAGER'), productsController.deleteProduct);

export default router;
