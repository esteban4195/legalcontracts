import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { UsersService, User } from '../../services/users.service';

@Component({
  selector: 'app-users',
  templateUrl: 'users.page.html',
  styleUrls: ['users.page.scss'],
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
})
export class UsersPage implements OnInit {
  users: User[] = [];
  filtered: User[] = [];
  loading = false;
  errorMsg = '';

  searchTerm = '';
  roleFilter = '';

  // Modal
  showModal = false;
  modalMode: 'create' | 'edit' = 'create';
  editingUser: User | null = null;
  form!: FormGroup;
  formError = '';
  formLoading = false;

  readonly roles = ['ADMIN', 'USUARIO', 'AUDITOR'];

  constructor(
    public auth: AuthService,
    private svc: UsersService,
    private fb: FormBuilder,
  ) {}

  get currentUser() { return this.auth.getCurrentUser(); }
  get isAdmin(): boolean { return this.currentUser?.system_role === 'ADMIN'; }

  get totalUsers()    { return this.users.length; }
  get activeUsers()   { return this.users.filter(u => u.is_active).length; }
  get inactiveUsers() { return this.users.filter(u => !u.is_active).length; }

  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading = true;
    this.errorMsg = '';
    this.svc.getAll().subscribe({
      next: (data) => { this.users = data; this.applyFilters(); this.loading = false; },
      error: () => { this.errorMsg = 'Error al cargar usuarios'; this.loading = false; },
    });
  }

  applyFilters(): void {
    const term = this.searchTerm.toLowerCase();
    this.filtered = this.users.filter(u => {
      const matchSearch = !term || u.name.toLowerCase().includes(term) || u.email.toLowerCase().includes(term);
      const matchRole   = !this.roleFilter || u.system_role === this.roleFilter;
      return matchSearch && matchRole;
    });
  }

  onSearch(e: Event): void {
    this.searchTerm = (e.target as HTMLInputElement).value;
    this.applyFilters();
  }

  onRoleFilter(e: Event): void {
    this.roleFilter = (e.target as HTMLSelectElement).value;
    this.applyFilters();
  }

  // ── Modal ────────────────────────────────────────────────────────────────

  openCreate(): void {
    this.modalMode = 'create';
    this.editingUser = null;
    this.formError = '';
    this.form = this.fb.group({
      name:        ['', Validators.required],
      email:       ['', [Validators.required, Validators.email]],
      password:    ['', Validators.required],
      system_role: ['USUARIO', Validators.required],
    });
    this.showModal = true;
  }

  openEdit(user: User): void {
    this.modalMode = 'edit';
    this.editingUser = user;
    this.formError = '';
    this.form = this.fb.group({
      name:        [user.name, Validators.required],
      email:       [user.email, [Validators.required, Validators.email]],
      system_role: [user.system_role, Validators.required],
    });
    this.showModal = true;
  }

  closeModal(): void { this.showModal = false; }

  submitForm(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.formLoading = true;
    this.formError = '';

    const obs = this.modalMode === 'create'
      ? this.svc.create(this.form.value)
      : this.svc.update(this.editingUser!.id, this.form.value);

    obs.subscribe({
      next: () => { this.showModal = false; this.load(); this.formLoading = false; },
      error: (err) => {
        this.formError = err.error?.detail || 'Error al guardar';
        this.formLoading = false;
      },
    });
  }

  toggle(user: User): void {
    this.svc.toggleActive(user.id).subscribe({
      next: () => this.load(),
      error: () => { this.errorMsg = 'Error al cambiar estado'; },
    });
  }

  // ── Helpers visuales ─────────────────────────────────────────────────────

  avatarLetter(name: string): string { return name.charAt(0).toUpperCase(); }

  avatarColor(name: string): string {
    const colors = ['#2563eb','#7c3aed','#059669','#d97706','#dc2626','#0891b2'];
    return colors[name.charCodeAt(0) % colors.length];
  }

  roleBadgeClass(role: string): string {
    return { ADMIN: 'badge-admin', USUARIO: 'badge-usuario', AUDITOR: 'badge-auditor' }[role] ?? '';
  }
}
