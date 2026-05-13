import { bootstrapApplication } from '@angular/platform-browser';
import { RouteReuseStrategy, provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { IonicRouteStrategy, provideIonicAngular } from '@ionic/angular/standalone';

import { AppComponent } from './app/app.component';
import { routes } from './app/app.routes';
import { authInterceptor } from './app/interceptors/auth.interceptor';

import { addIcons } from 'ionicons';
import {
  documentTextOutline,
  checkmarkDoneOutline,
  timeOutline,
  shieldCheckmarkOutline
} from 'ionicons/icons';

addIcons({
  'document-text-outline': documentTextOutline,
  'checkmark-done-outline': checkmarkDoneOutline,
  'time-outline': timeOutline,
  'shield-checkmark-outline': shieldCheckmarkOutline
});


bootstrapApplication(AppComponent, {
  providers: [
    { provide: RouteReuseStrategy, useClass: IonicRouteStrategy },
    provideIonicAngular(),
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
  ],
});
