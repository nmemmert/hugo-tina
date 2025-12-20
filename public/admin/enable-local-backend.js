// This script enables Netlify CMS local backend mode automatically
if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
  window.CMS_MANUAL_INIT = true;
  window.addEventListener('DOMContentLoaded', function() {
    window.CMS.init({ config: { local_backend: true } });
  });
}
