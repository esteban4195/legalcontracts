import { Component, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonIcon } from '@ionic/angular/standalone';
import { ActivatedRoute } from '@angular/router';
import { Subject, interval, switchMap, startWith, takeUntil } from 'rxjs';
import { ContractsService, ContractDetail } from '../../services/contracts.service';

@Component({
  selector: 'app-blockchain',
  templateUrl: 'blockchain.page.html',
  styleUrls: ['blockchain.page.scss'],
  standalone: true,
  imports: [CommonModule, IonIcon],
})
export class BlockchainPage implements OnDestroy {
  contractId: number | null = null;
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
    this.contractId = routeId ? Number(routeId) : null;
    this.start();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  private start(): void {
    const contractId = this.contractId;
    if (contractId !== null) {
      this.pollContract(contractId);
      return;
    }

    this.contractsService.listContracts()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (contracts: any[]) => {
          if (!contracts || contracts.length === 0) {
            this.loading = false;
            this.error = 'No hay contratos disponibles para mostrar la cadena.';
            return;
          }

          const newContractId = contracts[0].id;
          this.contractId = newContractId;
          this.pollContract(newContractId);
        },
        error: (err: any) => {
          this.loading = false;
          this.error = err?.message || 'Error al obtener la lista de contratos.';
        },
      });
  }

  private pollContract(contractId: number): void {
    interval(5000)
      .pipe(
        startWith(0),
        switchMap(() => this.contractsService.getContract(contractId)),
        takeUntil(this.destroy$),
      )
      .subscribe({
        next: (contract: ContractDetail) => {
          this.contract = contract;
          this.blockchain = contract.blockchain || [];
          this.loading = false;
          this.error = '';
        },
        error: (err: any) => {
          this.loading = false;
          this.error = err?.message || 'Error al obtener el detalle del contrato.';
        },
      });
  }

  getBlockClass(index: number): string {
    const classes = ['blue', 'purple', 'green'];
    return classes[index % classes.length];
  }
}
