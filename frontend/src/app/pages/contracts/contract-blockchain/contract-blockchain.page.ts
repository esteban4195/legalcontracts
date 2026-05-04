import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, ActivatedRoute } from '@angular/router';
import { ContractsService, ContractDetail, BlockchainBlock } from '../../../services/contracts.service';

@Component({
  selector: 'app-contract-blockchain',
  standalone: true,
  imports: [CommonModule],
  templateUrl: 'contract-blockchain.page.html',
  styleUrls: ['contract-blockchain.page.scss'],
})
export class ContractBlockchainPage implements OnInit {
  contract: ContractDetail | null = null;
  loading = false;
  errorMsg = '';

  contractId!: number;

  constructor(
    private router: Router,
    private route: ActivatedRoute,
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

  get blocks(): BlockchainBlock[] {
    return this.contract?.blockchain_blocks ?? [];
  }

  truncateHash(hash: string | null): string {
    if (!hash) return '-';
    return hash.length > 14 ? hash.slice(0, 14) + '...' : hash;
  }

  formatDate(dateStr: string): string {
    if (!dateStr) return '-';
    return new Date(dateStr).toLocaleString('es-CO');
  }

  eventLabel(type: string): string {
    return ({ GENESIS: 'Genesis', FIRMA: 'Firma', VALIDACION: 'Validación' } as Record<string, string>)[type] ?? type;
  }

  eventClass(type: string): string {
    return ({ GENESIS: 'event-genesis', FIRMA: 'event-firma', VALIDACION: 'event-validacion' } as Record<string, string>)[type] ?? '';
  }

  goBack(): void { this.router.navigate(['/contracts', this.contractId]); }
}
