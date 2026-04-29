import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';
import { MainLayoutComponent } from './layouts/main-layout/main-layout.component';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'dashboard',
    pathMatch: 'full',
  },
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login.page').then((m) => m.LoginPage),
  },
  {
    path: '',
    component: MainLayoutComponent,
    canActivate: [authGuard],
    children: [
      {
        path: 'dashboard',
        loadComponent: () => import('./pages/dashboard/dashboard.page').then((m) => m.DashboardPage),
      },
      {
        path: 'contracts',
        loadComponent: () => import('./pages/contracts/contracts.page').then((m) => m.ContractsPage),
      },
      {
        path: 'blockchain',
        loadComponent: () => import('./pages/blockchain/blockchain.page').then((m) => m.BlockchainPage),
      },
      {
        path: 'audit-logs',
        loadComponent: () => import('./pages/audit-logs/audit-logs.page').then((m) => m.AuditLogsPage),
      },
      {
        path: 'users',
        loadComponent: () => import('./pages/users/users.page').then((m) => m.UsersPage),
      },
      {
        path: 'cloud-providers',
        loadComponent: () => import('./pages/cloud-providers/cloud-providers.page').then((m) => m.CloudProvidersPage),
      },
      {
        path: 'settings',
        loadComponent: () => import('./pages/settings/settings.page').then((m) => m.SettingsPage),
      },
    ],
  },
  {
    path: '**',
    redirectTo: 'dashboard',
  },
];
