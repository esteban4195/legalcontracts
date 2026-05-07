import { Component, OnInit, ElementRef, ViewChild } from '@angular/core';
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
  @ViewChild('signatureCanvas') canvasRef!: ElementRef<HTMLCanvasElement>;

  contract: ContractDetail | null = null;
  loading = false;
  actionLoading = false;
  errorMsg = '';
  successMsg = '';

  // Validate modal
  showValidateModal = false;
  modalValidateError = '';

  // Sign modal
  showSignModal = false;
  modalSignError = '';
  signMode: 'draw' | 'upload' = 'draw';
  signaturePreview: string | null = null;
  isEditSignature = false;

  // Canvas drawing state
  private drawing = false;
  private ctx: CanvasRenderingContext2D | null = null;
  private lastX = 0;
  private lastY = 0;

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

  get canEditSignature(): boolean {
    if (!this.contract || this.isAuditor) return false;
    if (this.contract.status === 'VALIDADO') return false;
    const me = this.currentUser;
    if (!me) return false;
    const myPart = this.contract.participants.find(p => p.user_id === me.id);
    return !!myPart && myPart.has_signed;
  }

  get canValidate(): boolean {
    if (!this.contract || this.isAuditor) return false;
    if (this.contract.status !== 'FIRMADO') return false;
    return this.isAdmin || this.contract.created_by.id === this.currentUser?.id;
  }

  get nowString(): string {
    return new Date().toLocaleString('es-CO');
  }

  get lastBlock() {
    const blocks = this.contract?.blockchain_blocks;
    if (!blocks?.length) return null;
    return blocks[blocks.length - 1];
  }

  get myParticipant() {
    const me = this.currentUser;
    if (!me || !this.contract) return null;
    return this.contract.participants.find(p => p.user_id === me.id) ?? null;
  }

  // ── Sign modal ────────────────────────────────────────────────────────────

  openSignModal(isEdit = false): void {
    this.isEditSignature = isEdit;
    this.showSignModal = true;
    this.modalSignError = '';
    this.signMode = 'draw';
    this.signaturePreview = null;

    // If editing, pre-load existing signature
    if (isEdit && this.myParticipant?.signature_image_base64) {
      this.signaturePreview = this.myParticipant.signature_image_base64;
    }

    // Initialize canvas after view updates
    setTimeout(() => this.initCanvas(), 50);
  }

  closeSignModal(): void {
    this.showSignModal = false;
    this.signaturePreview = null;
    this.ctx = null;
  }

  setSignMode(mode: 'draw' | 'upload'): void {
    this.signMode = mode;
    if (mode === 'draw') {
      this.signaturePreview = null;
      setTimeout(() => this.initCanvas(), 50);
    }
  }

  // ── Canvas ────────────────────────────────────────────────────────────────

  private initCanvas(): void {
    if (!this.canvasRef) return;
    const canvas = this.canvasRef.nativeElement;
    this.ctx = canvas.getContext('2d');
    if (!this.ctx) return;
    this.ctx.strokeStyle = '#1e293b';
    this.ctx.lineWidth = 2.5;
    this.ctx.lineCap = 'round';
    this.ctx.lineJoin = 'round';
    this.clearCanvas();
  }

  clearCanvas(): void {
    if (!this.ctx || !this.canvasRef) return;
    const canvas = this.canvasRef.nativeElement;
    this.ctx.fillStyle = '#ffffff';
    this.ctx.fillRect(0, 0, canvas.width, canvas.height);
  }

  clearSignature(): void {
    if (this.signMode === 'draw') {
      this.clearCanvas();
    } else {
      this.signaturePreview = null;
    }
  }

  onCanvasMouseDown(e: MouseEvent): void {
    if (!this.ctx || !this.canvasRef) return;
    this.drawing = true;
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    this.lastX = e.clientX - rect.left;
    this.lastY = e.clientY - rect.top;
  }

  onCanvasMouseMove(e: MouseEvent): void {
    if (!this.drawing || !this.ctx || !this.canvasRef) return;
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    this.ctx.beginPath();
    this.ctx.moveTo(this.lastX, this.lastY);
    this.ctx.lineTo(x, y);
    this.ctx.stroke();
    this.lastX = x;
    this.lastY = y;
  }

  onCanvasMouseUp(): void { this.drawing = false; }
  onCanvasMouseLeave(): void { this.drawing = false; }

  onCanvasTouchStart(e: TouchEvent): void {
    e.preventDefault();
    if (!this.ctx || !this.canvasRef) return;
    this.drawing = true;
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    const touch = e.touches[0];
    this.lastX = touch.clientX - rect.left;
    this.lastY = touch.clientY - rect.top;
  }

  onCanvasTouchMove(e: TouchEvent): void {
    e.preventDefault();
    if (!this.drawing || !this.ctx || !this.canvasRef) return;
    const rect = this.canvasRef.nativeElement.getBoundingClientRect();
    const touch = e.touches[0];
    const x = touch.clientX - rect.left;
    const y = touch.clientY - rect.top;
    this.ctx.beginPath();
    this.ctx.moveTo(this.lastX, this.lastY);
    this.ctx.lineTo(x, y);
    this.ctx.stroke();
    this.lastX = x;
    this.lastY = y;
  }

  onCanvasTouchEnd(): void { this.drawing = false; }

  // ── Upload ────────────────────────────────────────────────────────────────

  onFileSelected(e: Event): void {
    const input = e.target as HTMLInputElement;
    const file = input.files?.[0];
    if (!file) return;
    const allowed = ['image/png', 'image/jpeg', 'image/jpg'];
    if (!allowed.includes(file.type)) {
      this.modalSignError = 'Solo se permiten imágenes PNG o JPG';
      return;
    }
    const reader = new FileReader();
    reader.onload = () => { this.signaturePreview = reader.result as string; };
    reader.readAsDataURL(file);
  }

  // ── Confirm sign / update ─────────────────────────────────────────────────

  confirmSign(): void {
    const base64 = this.getSignatureBase64();
    if (!base64) {
      this.modalSignError = 'Debes dibujar o subir una firma antes de confirmar';
      return;
    }

    this.actionLoading = true;
    this.modalSignError = '';

    const call = this.isEditSignature
      ? this.svc.updateSignature(this.contractId, base64)
      : this.svc.sign(this.contractId, base64);

    call.subscribe({
      next: (data) => {
        this.contract = data;
        this.actionLoading = false;
        this.successMsg = this.isEditSignature
          ? 'Firma actualizada correctamente'
          : 'Contrato firmado correctamente';
        this.closeSignModal();
      },
      error: (err) => {
        this.actionLoading = false;
        this.modalSignError = err.error?.detail || 'Error al procesar la firma';
      },
    });
  }

  private getSignatureBase64(): string | null {
    if (this.signMode === 'upload') {
      return this.signaturePreview || null;
    }
    // Draw mode: export canvas
    if (!this.canvasRef) return null;
    const canvas = this.canvasRef.nativeElement;
    // Check if canvas has any drawing (not all white)
    const ctx = canvas.getContext('2d');
    if (!ctx) return null;
    const data = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
    const hasDrawing = Array.from(data).some((v, i) => i % 4 !== 3 && v < 250);
    if (!hasDrawing) return null;
    return canvas.toDataURL('image/png');
  }

  // ── Validate modal ────────────────────────────────────────────────────────

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

  // ── Navigation ────────────────────────────────────────────────────────────

  goEdit(): void { this.router.navigate(['/contracts', this.contractId, 'edit']); }
  goBlockchain(): void { this.router.navigate(['/contracts', this.contractId, 'blockchain']); }
  goBack(): void { this.router.navigate(['/contracts']); }

  // ── Helpers ───────────────────────────────────────────────────────────────

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
