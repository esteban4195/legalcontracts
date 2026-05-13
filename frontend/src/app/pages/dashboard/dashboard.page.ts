import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { IonicModule } from '@ionic/angular';
import { DashboardService, DashboardSummary } from '../../services/dashboard.service';

@Component({
    selector: 'app-dashboard',
    templateUrl: './dashboard.page.html',
    styleUrls: ['./dashboard.page.scss'],
    standalone: true,
    imports: [CommonModule, IonicModule]
})
export class DashboardPage implements OnInit {

    summary: DashboardSummary | null = null;

    loading = true;

    errorMessage = '';

    constructor(private dashboardService: DashboardService) { }

    ngOnInit(): void {
        this.loadDashboard();
    }
    // con datos reales del backend
    // loadDashboard(): void {

    //     this.loading = true;

    //     this.dashboardService.getSummary().subscribe({

    //         next: (data) => {

    //             this.summary = data;

    //             this.loading = false;
    //         },

    //         error: () => {

    //             this.loading = false;

    //             this.errorMessage =
    //                 'Información no disponible en el momento.';
    //         }
    //     });
    // }

    // con datos simulados para pruebas sin backend
    loadDashboard(): void {

        this.loading = true;

        setTimeout(() => {

            this.summary = {

                total_contracts: 248,

                signed_contracts: 186,

                draft_contracts: 42,

                validated_contracts: 156,

                active_users: 24,

                active_providers: 8,

                recent_contracts: [

                    {
                        id: 1,
                        title: 'Contrato de Servicios TI',
                        status: 'FIRMADO',
                        provider: 'AWS',
                        date: '2026-04-28'
                    },

                    {
                        id: 2,
                        title: 'Acuerdo de Confidencialidad',
                        status: 'VALIDADO',
                        provider: 'Azure',
                        date: '2026-04-27'
                    },

                    {
                        id: 3,
                        title: 'Contrato de Consultoría',
                        status: 'BORRADOR',
                        provider: 'GCP',
                        date: '2026-04-26'
                    },

                    {
                        id: 4,
                        title: 'Licencia de Software',
                        status: 'FIRMADO',
                        provider: 'AWS',
                        date: '2026-04-25'
                    }

                ]

            };

            this.loading = false;

        }, 1000);

    }

    
}