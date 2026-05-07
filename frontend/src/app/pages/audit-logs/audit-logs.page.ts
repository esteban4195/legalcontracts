import { Component, OnInit } from "@angular/core";
import { CommonModule } from "@angular/common";
import { FormsModule } from "@angular/forms";

@Component({
  selector: "app-audit-logs",
  templateUrl: "audit-logs.page.html",
  styleUrls: ["audit-logs.page.scss"],
  standalone: true,
  imports: [CommonModule, FormsModule],
})
export class AuditLogsPage implements OnInit {
  // Simulación temporal de logs a espera de backend (Nasly)
  logs: any[] = [];

  filteredLogs: any[] = [];

  selectedAction: string = "";
  selectedUser: string = "";

  isForbidden = false;
  isLoading = false;

  ngOnInit(): void {
    this.logs = [
      {
        fecha: "2026-04-29 08:30:15",
        accion: "LOGIN",
        contrato: "-",
        usuario: "Admin Usuario",
        detalles: "Inicio de sesión exitoso",
      },
      {
        fecha: "2026-04-29 09:15:42",
        accion: "CREACION_CONTRATO",
        contrato: "#1",
        usuario: "Admin Usuario",
        detalles: "Contrato de Servicios TI",
      },
      {
        fecha: "2026-04-29 10:22:18",
        accion: "FIRMA",
        contrato: "#1",
        usuario: "Juan Pérez",
        detalles: "Firma aplicada al contrato",
      },
      {
        fecha: "2026-04-29 10:23:05",
        accion: "VALIDACION",
        contrato: "#1",
        usuario: "Sistema",
        detalles: "Validación exitosa",
      },
    ];

    this.filteredLogs = [...this.logs];
  }

  applyFilters(): void {

  this.filteredLogs = this.logs.filter(log => {

    const matchAction =
      !this.selectedAction ||
      log.accion.toLowerCase().includes(this.selectedAction.toLowerCase());

    const matchUser =
      !this.selectedUser ||
      log.usuario.toLowerCase().includes(this.selectedUser.toLowerCase());

    return matchAction && matchUser;
  });
}

  getActionClass(action: string): string {

  switch (action) {

    case 'LOGIN':
      return 'badge-login';

    case 'LOGOUT':
      return 'badge-logout';

    case 'FIRMA':
      return 'badge-sign';

    case 'VALIDACION':
      return 'badge-validation';

    case 'CREACION_CONTRATO':
      return 'badge-create';

    case 'AGREGAR_PARTICIPANTE':
      return 'badge-add';

    case 'ELIMINAR_PARTICIPANTE':
      return 'badge-remove';

    case 'EDICION_CONTRATO':
      return 'badge-edit';

    case 'ERROR_VALIDACION_PROVEEDOR':
      return 'badge-error';

    default:
      return 'badge-default';
  }
}
}
