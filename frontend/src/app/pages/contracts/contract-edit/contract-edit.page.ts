import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { ContractsService } from '../../../services/contracts.service';
import { UsersService, User } from '../../../services/users.service';
import { CloudProvidersService, CloudProvider } from '../../../services/cloud-providers.service';

interface ParticipantEntry {
  user_id: number;
  user_name: string;
  role_in_contract: 'CLIENTE' | 'PROVEEDOR' | 'TESTIGO';
}

@Component({
  selector: 'app-contract-edit',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: 'contract-edit.page.html',
  styleUrls: ['contract-edit.page.scss'],
})
export class ContractEditPage implements OnInit {
  title = '';
  content = '';
  contains_sensitive_data = false;
  selectedProviderId: number | null = null;

  users: User[] = [];
  providers: CloudProvider[] = [];

  selectedUserId: number | null = null;
  selectedRole: 'CLIENTE' | 'PROVEEDOR' | 'TESTIGO' = 'CLIENTE';
  participants: ParticipantEntry[] = [];

  readonly roleOptions: { value: 'CLIENTE' | 'PROVEEDOR' | 'TESTIGO'; label: string }[] = [
    { value: 'CLIENTE', label: 'Cliente' },
    { value: 'PROVEEDOR', label: 'Proveedor' },
    { value: 'TESTIGO', label: 'Testigo' },
  ];

  loading = false;
  loadingUsers = false;
  loadingProviders = false;
  saving = false;
  errorMsg = '';
  successMsg = '';

  private contractId!: number;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
    private contractsSvc: ContractsService,
    private usersSvc: UsersService,
    private providersSvc: CloudProvidersService,
  ) {}

  ngOnInit(): void {
    this.contractId = Number(this.route.snapshot.paramMap.get('id'));
    this.loadAll();
  }

  loadAll(): void {
    this.loading = true;
    this.loadingUsers = true;
    this.loadingProviders = true;

    this.contractsSvc.getById(this.contractId).subscribe({
      next: (c) => {
        this.title = c.title;
        this.content = c.content;
        this.contains_sensitive_data = c.contains_sensitive_data;
        this.selectedProviderId = c.cloud_provider.id;
        this.participants = c.participants.map(p => ({
          user_id: p.user_id,
          user_name: p.user_name,
          role_in_contract: p.role_in_contract,
        }));
        this.loading = false;
      },
      error: () => { this.errorMsg = 'Error al cargar el contrato'; this.loading = false; },
    });

    this.usersSvc.getAll().subscribe({
      next: (data) => { this.users = data.filter(u => u.is_active); this.loadingUsers = false; },
      error: () => { this.loadingUsers = false; },
    });

    this.providersSvc.getAll().subscribe({
      next: (data) => { this.providers = data.filter(p => p.is_active); this.loadingProviders = false; },
      error: () => { this.loadingProviders = false; },
    });
  }

  get selectedProvider(): CloudProvider | null {
    if (!this.selectedProviderId) return null;
    return this.providers.find(p => p.id === +this.selectedProviderId!) ?? null;
  }

  get availableUsers(): User[] {
    const addedIds = new Set(this.participants.map(p => p.user_id));
    return this.users.filter(u => !addedIds.has(u.id));
  }

  addParticipant(): void {
    if (!this.selectedUserId) return;
    const uid = +this.selectedUserId;
    if (this.participants.some(p => p.user_id === uid)) return;
    const user = this.users.find(u => u.id === uid);
    if (!user) return;
    this.participants.push({ user_id: uid, user_name: user.name, role_in_contract: this.selectedRole });
    this.selectedUserId = null;
    this.selectedRole = 'CLIENTE';
  }

  removeParticipant(userId: number): void {
    this.participants = this.participants.filter(p => p.user_id !== userId);
  }

  roleBadgeClass(role: string): string {
    return ({ CLIENTE: 'badge-cliente', PROVEEDOR: 'badge-proveedor', TESTIGO: 'badge-testigo' } as Record<string, string>)[role] ?? '';
  }

  roleLabel(role: string): string {
    return ({ CLIENTE: 'Cliente', PROVEEDOR: 'Proveedor', TESTIGO: 'Testigo' } as Record<string, string>)[role] ?? role;
  }

  validate(): string | null {
    if (!this.title.trim()) return 'El título es requerido';
    if (!this.content.trim()) return 'El contenido es requerido';
    if (!this.selectedProviderId) return 'Debe seleccionar un proveedor de nube';
    if (this.participants.length < 2) return 'Se requieren mínimo 2 participantes';
    return null;
  }

  save(): void {
    this.errorMsg = '';
    this.successMsg = '';
    const err = this.validate();
    if (err) { this.errorMsg = err; return; }

    this.saving = true;
    const payload = {
      title: this.title.trim(),
      content: this.content.trim(),
      contains_sensitive_data: this.contains_sensitive_data,
      cloud_provider_id: +this.selectedProviderId!,
      participants: this.participants.map(p => ({ user_id: p.user_id, role_in_contract: p.role_in_contract })),
    };

    this.contractsSvc.update(this.contractId, payload).subscribe({
      next: () => {
        this.saving = false;
        this.router.navigate(['/contracts', this.contractId]);
      },
      error: (err) => {
        this.saving = false;
        this.errorMsg = err.error?.detail || 'Error al guardar el contrato';
      },
    });
  }

  cancel(): void {
    this.router.navigate(['/contracts', this.contractId]);
  }
}
