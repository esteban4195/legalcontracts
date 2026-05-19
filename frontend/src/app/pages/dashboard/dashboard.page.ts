import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule } from '@ionic/angular';
import { RouterModule } from '@angular/router';
import { DashboardService, DashboardSummary } from '../../services/dashboard.service';

const MONTH_NAMES = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];

@Component({
    selector: 'app-dashboard',
    templateUrl: './dashboard.page.html',
    styleUrls: ['./dashboard.page.scss'],
    standalone: true,
    imports: [CommonModule, IonicModule, RouterModule]
})
export class DashboardPage implements OnInit {

    summary: DashboardSummary | null = null;
    loading = true;
    errorMessage = '';

    constructor(private dashboardService: DashboardService) { }

    ngOnInit(): void {
        this.loadDashboard();
    }

    loadDashboard(): void {
        this.loading = true;
        this.dashboardService.getSummary().subscribe({
            next: (data) => {
                this.summary = data;
                this.loading = false;
            },
            error: () => {
                this.loading = false;
                this.errorMessage = 'Información no disponible en el momento.';
            }
        });
    }

    getMonthName(month: number): string {
        return MONTH_NAMES[month - 1] || '';
    }

    getBarHeight(total: number): string {
        const max = Math.max(...(this.summary?.contracts_by_month.map(m => m.total) ?? [1]));
        return `${Math.round((total / max) * 90) + 10}%`;
    }

    getActionLabel(action: string): string {
        const labels: Record<string, string> = {
            CREACION_CONTRATO: 'Contrato creado',
            AGREGAR_PARTICIPANTE: 'Participante agregado',
            ELIMINAR_PARTICIPANTE: 'Participante eliminado',
            EDICION_CONTRATO: 'Contrato editado',
            FIRMA: 'Contrato firmado',
            ACTUALIZACION_FIRMA: 'Firma actualizada',
            VALIDACION: 'Contrato validado',
            ERROR_VALIDACION_PROVEEDOR: 'Error de validación',
        };
        return labels[action] ?? action;
    }
}