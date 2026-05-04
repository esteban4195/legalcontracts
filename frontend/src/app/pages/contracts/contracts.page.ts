import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { ContractsService, Contract } from '../../services/contracts.service';

@Component({
  selector: 'app-contracts',
  templateUrl: 'contracts.page.html',
  styleUrls: ['contracts.page.scss'],
  standalone: true,
  imports: [CommonModule],
})
export class ContractsPage implements OnInit {
  contracts: Contract[] = [];
  filtered: Contract[] = [];
  loading = false;
  errorMsg = '';

  searchTerm = '';
  statusFilter = '';

  readonly statusOptions = [
    { value: '', label: 'Todos los estados' },
    { value: 'BORRADOR', label: 'Borrador' },
    { value: 'FIRMADO', label: 'Firmado' },
    { value: 'VALIDADO', label: 'Validado' },
  ];

  constructor(
    public auth: AuthService,
    private svc: ContractsService,
    private router: Router,
  ) {}

  get currentUser() { return this.auth.getCurrentUser(); }
  get isAdmin(): boolean { return this.currentUser?.system_role === 'ADMIN'; }
  get isAuditor(): boolean { return this.currentUser?.system_role === 'AUDITOR'; }

  get totalContracts() { return this.contracts.length; }
  get draftCount() { return this.contracts.filter(c => c.status === 'BORRADOR').length; }
  get signedCount() { return this.contracts.filter(c => c.status === 'FIRMADO').length; }
  get validatedCount() { return this.contracts.filter(c => c.status === 'VALIDADO').length; }

  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading = true;
    this.errorMsg = '';
    this.svc.getAll().subscribe({
      next: (data) => { this.contracts = data; this.applyFilters(); this.loading = false; },
      error: () => { this.errorMsg = 'Error al cargar contratos'; this.loading = false; },
    });
  }

  applyFilters(): void {
    const term = this.searchTerm.toLowerCase();
    this.filtered = this.contracts.filter(c => {
      const matchSearch = !term || c.title.toLowerCase().includes(term);
      const matchStatus = !this.statusFilter || c.status === this.statusFilter;
      return matchSearch && matchStatus;
    });
  }

  onSearch(e: Event): void {
    this.searchTerm = (e.target as HTMLInputElement).value;
    this.applyFilters();
  }

  onStatusFilter(e: Event): void {
    this.statusFilter = (e.target as HTMLSelectElement).value;
    this.applyFilters();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  openCreate(): void {
    this.router.navigate(['/contracts/new']);
  }

  viewContract(id: number): void {
    this.router.navigate(['/contracts', id]);
  }

  editContract(id: number): void {
    this.router.navigate(['/contracts', id, 'edit']);
  }

  signContract(id: number): void {
    this.router.navigate(['/contracts', id]);
  }

  validateContract(id: number): void {
    this.router.navigate(['/contracts', id]);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  canEdit(c: Contract): boolean {
    if (this.isAuditor) return false;
    return c.status === 'BORRADOR';
  }

  canSign(c: Contract): boolean {
    if (this.isAuditor) return false;
    if (c.status !== 'BORRADOR') return false;
    return c.signed_participants < c.total_participants;
  }

  canValidate(c: Contract): boolean {
    if (!this.isAdmin) return false;
    return c.status === 'FIRMADO';
  }

  formatDate(dateStr: string): string {
    if (!dateStr) return '-';
    const d = new Date(dateStr);
    return d.toLocaleDateString('es-CO', { year: 'numeric', month: 'short', day: 'numeric' });
  }

  statusLabel(status: string): string {
    return ({ BORRADOR: 'Borrador', FIRMADO: 'Firmado', VALIDADO: 'Validado' } as Record<string, string>)[status] ?? status;
  }
}
