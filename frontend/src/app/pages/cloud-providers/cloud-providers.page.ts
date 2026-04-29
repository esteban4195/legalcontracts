import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth.service';
import { CloudProvidersService, CloudProvider } from '../../services/cloud-providers.service';

@Component({
  selector: 'app-cloud-providers',
  templateUrl: 'cloud-providers.page.html',
  styleUrls: ['cloud-providers.page.scss'],
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
})
export class CloudProvidersPage implements OnInit {
  providers: CloudProvider[] = [];
  filtered: CloudProvider[] = [];
  loading = false;
  errorMsg = '';

  searchTerm = '';

  showModal = false;
  modalMode: 'create' | 'edit' = 'create';
  editingProvider: CloudProvider | null = null;
  form!: FormGroup;
  formError = '';
  formLoading = false;

  readonly locationOptions = [
    { value: 'DENTRO_PAIS', label: 'Dentro del país' },
    { value: 'FUERA_PAIS',  label: 'Fuera del país' },
  ];

  constructor(
    public auth: AuthService,
    private svc: CloudProvidersService,
    private fb: FormBuilder,
  ) {}

  get currentUser()  { return this.auth.getCurrentUser(); }
  get isAdmin(): boolean { return this.currentUser?.system_role === 'ADMIN'; }

  get totalProviders()   { return this.providers.length; }
  get activeProviders()  { return this.providers.filter(p => p.is_active).length; }
  get insideCountry()    { return this.providers.filter(p => p.location_type === 'DENTRO_PAIS' && p.is_active).length; }
  get sensitiveCnt()     { return this.providers.filter(p => p.allows_sensitive_data && p.is_active).length; }

  ngOnInit(): void { this.load(); }

  load(): void {
    this.loading = true;
    this.errorMsg = '';
    this.svc.getAll().subscribe({
      next: (data) => { this.providers = data; this.applyFilters(); this.loading = false; },
      error: () => { this.errorMsg = 'Error al cargar proveedores'; this.loading = false; },
    });
  }

  applyFilters(): void {
    const term = this.searchTerm.toLowerCase();
    this.filtered = this.providers.filter(p =>
      !term ||
      p.name.toLowerCase().includes(term) ||
      p.region.toLowerCase().includes(term) ||
      p.country.toLowerCase().includes(term)
    );
  }

  onSearch(e: Event): void {
    this.searchTerm = (e.target as HTMLInputElement).value;
    this.applyFilters();
  }

  // ── Modal ────────────────────────────────────────────────────────────────────

  openCreate(): void {
    this.modalMode = 'create';
    this.editingProvider = null;
    this.formError = '';
    this.form = this.fb.group({
      name:                  ['', Validators.required],
      region:                ['', Validators.required],
      country:               ['', Validators.required],
      allows_sensitive_data: [false, Validators.required],
      location_type:         ['DENTRO_PAIS', Validators.required],
    });
    this.showModal = true;
  }

  openEdit(p: CloudProvider): void {
    this.modalMode = 'edit';
    this.editingProvider = p;
    this.formError = '';
    this.form = this.fb.group({
      name:                  [p.name,                  Validators.required],
      region:                [p.region,                Validators.required],
      country:               [p.country,               Validators.required],
      allows_sensitive_data: [p.allows_sensitive_data, Validators.required],
      location_type:         [p.location_type,         Validators.required],
    });
    this.showModal = true;
  }

  closeModal(): void { this.showModal = false; }

  submitForm(): void {
    if (this.form.invalid) { this.form.markAllAsTouched(); return; }
    this.formLoading = true;
    this.formError = '';

    // Coerce checkbox value to boolean
    const payload = { ...this.form.value, allows_sensitive_data: !!this.form.value.allows_sensitive_data };

    const obs = this.modalMode === 'create'
      ? this.svc.create(payload)
      : this.svc.update(this.editingProvider!.id, payload);

    obs.subscribe({
      next: () => { this.showModal = false; this.load(); this.formLoading = false; },
      error: (err) => {
        this.formError = err.error?.detail || 'Error al guardar';
        this.formLoading = false;
      },
    });
  }

  toggle(p: CloudProvider): void {
    this.svc.toggleActive(p.id).subscribe({
      next: () => this.load(),
      error: () => { this.errorMsg = 'Error al cambiar estado'; },
    });
  }

  // ── Helpers visuales ─────────────────────────────────────────────────────────

  providerInitial(name: string): string { return name.charAt(0).toUpperCase(); }

  providerColor(name: string): string {
    const colors = ['#2563eb', '#7c3aed', '#0891b2', '#d97706', '#059669', '#dc2626'];
    return colors[name.charCodeAt(0) % colors.length];
  }
}
