import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { ContractsService, ContractDetail } from '../../../services/contracts.service';

@Component({
  selector: 'app-contract-detail',
  standalone: true,
  imports: [CommonModule],
  templateUrl: 'contract-detail.page.html',
  styleUrls: ['contract-detail.page.scss'],
})
export class ContractDetailPage implements OnInit {
  contract: ContractDetail | null = null;
  loading = false;
  actionLoading = false;
  errorMsg = '';
  successMsg = '';

  showSignModal = false;
  modalSignError = '';

  showValidateModal = false;
  modalValidateError = '';

  private contractId!: number;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private auth: AuthService,
    private svc: ContractsService,
  ) {}

  ngOnInit(): void {
    this.contractId = Number(this.route.snapshot.paramMap.get('id'));
    this.load();
  }

  load(): void {
    this.loading = true;
    this.errorMsg = '';
    this.svc.getById(this.contractId).subscribe({
      next: (data) => { this.contract = data; this.loading = false; },
      error: () => { this.errorMsg = 'Error al cargar el contrato'; this.loading = false; },
    });
  }

  get currentUser() { return this.auth.getCurrentUser(); }
  get totalCount(): number { return this.contract?.participants?.length ?? 0; }
  get signedCount(): number { return this.contract?.participants?.filter(p => p.has_signed).length ?? 0; }
  get isAdmin(): boolean { return this.currentUser?.system_role === 'ADMIN'; }
  get isAuditor(): boolean { return this.currentUser?.system_role === 'AUDITOR'; }

  get canEdit(): boolean {
    if (!this.contract || this.isAuditor) return false;
    if (this.contract.status !== 'BORRADOR') return false;
    return this.isAdmin || this.contract.created_by.id === this.currentUser?.id;
  }

  get canSign(): boolean {
    if (!this.contract || this.isAuditor) return false;
    if (this.contract.status !== 'BORRADOR') return false;
    const me = this.currentUser;
    if (!me) return false;
    const myPart = this.contract.participants.find(p => p.user_id === me.id);
    return !!myPart && !myPart.has_signed;
  }

  get canValidate(): boolean {
    if (!this.contract || this.isAuditor) return false;
    if (this.contract.status !== 'FIRMADO') return false;
    return this.isAdmin || this.contract.created_by.id === this.currentUser?.id;
  }

  get nowString(): string {
    return new Date().toLocaleString('es-CO');
  }

  openSignModal(): void {
    this.showSignModal = true;
    this.modalSignError = '';
  }

  closeSignModal(): void {
    this.showSignModal = false;
  }

  confirmSign(): void {
    this.actionLoading = true;
    this.modalSignError = '';
    this.svc.sign(this.contractId).subscribe({
      next: (data) => {
        this.contract = data;
        this.actionLoading = false;
        this.successMsg = 'Contrato firmado correctamente';
        this.closeSignModal();
      },
      error: (err) => {
        this.actionLoading = false;
        this.modalSignError = err.error?.detail || 'Error al firmar el contrato';
      },
    });
  }

  openValidateModal(): void {
    this.showValidateModal = true;
    this.modalValidateError = '';
  }

  closeValidateModal(): void {
    this.showValidateModal = false;
  }

  confirmValidate(): void {
    this.actionLoading = true;
    this.modalValidateError = '';
    this.svc.validate(this.contractId).subscribe({
      next: (data) => {
        this.contract = data;
        this.actionLoading = false;
        this.successMsg = 'Contrato validado correctamente';
        this.closeValidateModal();
      },
      error: (err) => {
        this.actionLoading = false;
        this.modalValidateError = err.error?.detail || 'Error al validar el contrato';
      },
    });
  }

  goEdit(): void { this.router.navigate(['/contracts', this.contractId, 'edit']); }
  goBlockchain(): void { this.router.navigate(['/contracts', this.contractId, 'blockchain']); }
  goBack(): void { this.router.navigate(['/contracts']); }

  formatDate(dateStr: string): string {
    if (!dateStr) return '-';
    return new Date(dateStr).toLocaleDateString('es-CO', { year: 'numeric', month: 'short', day: 'numeric' });
  }

  statusLabel(status: string): string {
    return ({ BORRADOR: 'Borrador', FIRMADO: 'Firmado', VALIDADO: 'Validado' } as Record<string, string>)[status] ?? status;
  }

  statusBadgeClass(status: string): string {
    return ({ BORRADOR: 'badge-borrador', FIRMADO: 'badge-firmado', VALIDADO: 'badge-validado' } as Record<string, string>)[status] ?? '';
  }

  roleLabel(role: string): string {
    return ({ CLIENTE: 'Cliente', PROVEEDOR: 'Proveedor', TESTIGO: 'Testigo' } as Record<string, string>)[role] ?? role;
  }

  roleBadgeClass(role: string): string {
    return ({ CLIENTE: 'badge-cliente', PROVEEDOR: 'badge-proveedor', TESTIGO: 'badge-testigo' } as Record<string, string>)[role] ?? '';
  }

  blockLabel(type: string): string {
    return ({ GENESIS: 'Génesis', FIRMA: 'Firma', VALIDACION: 'Validación' } as Record<string, string>)[type] ?? type;
  }

  blockBadgeClass(type: string): string {
    return ({ GENESIS: 'badge-genesis', FIRMA: 'badge-firma', VALIDACION: 'badge-validacion' } as Record<string, string>)[type] ?? '';
  }
}
