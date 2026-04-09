import { Router } from 'express';
import * as categoriesController from '../controllers/categories';
import { authMiddleware, requireRole } from '../middleware/auth';

const router = Router();

router.get('/', authMiddleware, categoriesController.getAllCategories);
router.get('/:id', authMiddleware, categoriesController.getCategoryById);
router.post('/', authMiddleware, requireRole('ADMIN', 'MANAGER'), categoriesController.createCategory);
router.put('/:id', authMiddleware, requireRole('ADMIN', 'MANAGER'), categoriesController.updateCategory);
router.delete('/:id', authMiddleware, requireRole('ADMIN', 'MANAGER'), categoriesController.deleteCategory);

export default router;
