import { Component, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonIcon, IonSelect, IonSelectOption } from '@ionic/angular/standalone';
import { ActivatedRoute } from '@angular/router';
import { Subject, takeUntil } from 'rxjs';
import { ContractsService, ContractDetail, Contract } from '../../services/contracts.service';

@Component({
  selector: 'app-blockchain',
  templateUrl: 'blockchain.page.html',
  styleUrls: ['blockchain.page.scss'],
  standalone: true,
  imports: [CommonModule, IonIcon, IonSelect, IonSelectOption],
})
export class BlockchainPage implements OnDestroy {
  contractId: number | null = null;
  allContracts: Contract[] = [];
  contract: ContractDetail | null = null;
  blockchain: any[] = [];
  loading = true;
  error = '';

  private destroy$ = new Subject<void>();

  constructor(
    private route: ActivatedRoute,
    private contractsService: ContractsService,
  ) {
    const routeId = this.route.snapshot.paramMap.get('id');
    if (routeId) {
      this.contractId = Number(routeId);
    }
    this.loadContracts();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private loadContracts(): void {
    this.contractsService.getAll()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (contracts: Contract[]) => {
          this.allContracts = contracts || [];
          if (this.contractId) {
            this.loadContractDetail(this.contractId);
          } else if (this.allContracts.length > 0) {
            this.contractId = this.allContracts[0].id;
            this.loadContractDetail(this.contractId);
          } else {
            this.loading = false;
            this.error = 'No hay contratos disponibles para mostrar la cadena.';
          }
        },
        error: (err: any) => {
          this.loading = false;
          this.error = err?.message || 'Error al obtener la lista de contratos.';
        },
      });
  }

  onContractChange(event: any): void {
    const newId = event.detail.value;
    this.contractId = newId;
    this.contract = null;
    this.blockchain = [];
    this.loading = true;
    this.error = '';
    this.loadContractDetail(newId);
  }

  private loadContractDetail(contractId: number): void {
    this.contractsService.getById(contractId)
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (contract: ContractDetail) => {
          this.contract = contract;
          this.blockchain = contract.blockchain_blocks || [];
          this.loading = false;
          this.error = '';
        },
        error: (err: any) => {
          this.loading = false;
          this.error = err?.message || 'Error al obtener el detalle del contrato.';
        },
      });
  }

  getBlockClass(idx: number): string {
    const block = this.blockchain[idx];
    if (!block) return 'block-default';
    switch (block.event_type) {
      case 'GENESIS': return 'block-genesis';
      case 'FIRMA': return 'block-pending';
      case 'VALIDACION': return 'block-confirmed';
      default: return 'block-default';
    }
  }

  compareById(a: any, b: any): boolean {
    return a?.id === b?.id;
  }
}
