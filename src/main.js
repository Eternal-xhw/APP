if (typeof GM_xmlhttpRequest !== 'function') {
    console.warn('未检测到GM_xmlhttpRequest，正在使用Fetch作为替代方案。请注意跨域请求可能会失败，除非您配置了代理或禁用了Web安全策略。');
    // Polyfill using fetch
    window.GM_xmlhttpRequest = (details) => {
        const method = details.method || 'GET';
        const headers = details.headers || {};
        const body = details.data;

        // Check if the URL is an absolute Zhihu URL and convert to proxy if needed
        let fetchUrl = details.url;
        if (fetchUrl.includes('://api.zhihu.com')) {
          // Replace both http and https versions
          fetchUrl = fetchUrl.replace(/https?:\/\/api\.zhihu\.com/, '/zhihu_web/proxy/api');
        } else if (fetchUrl.includes('://www.zhihu.com')) {
           // Also proxy www.zhihu.com if necessary (though API is usually api.zhihu.com)
           fetchUrl = fetchUrl.replace(/https?:\/\/www\.zhihu\.com/, '/zhihu_web/proxy/www');
        }

        // Create a copy of headers to modify for fetch
        const requestHeaders = {};
        if (details.headers) {
             // Lowercase keys to consistent processing
             for (const key in details.headers) {
                 requestHeaders[key] = details.headers[key];
                 // Also support case-insensitive header access
             }
        }

        // Handle Cookie: GM_xmlhttpRequest might have it in headers or details.cookie
        let cookie = requestHeaders['Cookie'] || requestHeaders['cookie'] || details.cookie;
        if (cookie) {
            // Remove safe Cookie header (browser forbids setting it) and move to custom header for proxy
            delete requestHeaders['Cookie'];
            delete requestHeaders['cookie'];
            requestHeaders['X-Proxy-Cookie'] = cookie;
        }

        // Handle User-Agent
        const userAgent = requestHeaders['User-Agent'] || requestHeaders['user-agent'];
        if (userAgent) {
            delete requestHeaders['User-Agent'];
            delete requestHeaders['user-agent'];
            requestHeaders['X-Proxy-User-Agent'] = userAgent;
        }
        
        // Handle Referer and Origin if they exist (though proxy sets them, passing signals intent)
        const referer = requestHeaders['Referer'] || requestHeaders['referer'];
        if (referer) {
             delete requestHeaders['Referer'];
             delete requestHeaders['referer'];
             requestHeaders['X-Proxy-Referer'] = referer;
        }

        const origin = requestHeaders['Origin'] || requestHeaders['origin'];
        if (origin) {
             delete requestHeaders['Origin'];
             delete requestHeaders['origin'];
             requestHeaders['X-Proxy-Origin'] = origin;
        }

        fetch(fetchUrl, {
            method,
            headers: requestHeaders,
            body
        })
        .then(async response => {
            const text = await response.text();
            const responseHeaders = [...response.headers].map(([key, value]) => `${key}: ${value}`).join('\n');
            
            details.onload({
                status: response.status,
                statusText: response.statusText,
                responseText: text,
                responseHeaders: responseHeaders,
                finalUrl: response.url
            });
        })
        .catch(err => {
            console.error('Fetch error:', err);
            if (details.onerror) {
                details.onerror({ error: err.message });
            }
        });
    };
}

// if (typeof GM_xmlhttpRequest !== 'function') {
//     alert('未检测到GM_xmlhttpRequest！请检查是否已安装插件并安装脚本');
//     window.location.replace('https://scriptcat.org/script-show-page/5149');
// }

import { createApp } from 'vue';
import Framework7 from 'framework7/lite-bundle';
import Framework7Vue, { registerComponents } from 'framework7-vue/bundle';
import 'framework7/css/bundle';

// Import Icons and App Custom Styles
import './css/icons.css';
import './css/app.css';

import './style.css';
import App from './App.vue';
import $http from './api/http.js';
import * as zhihuModule from './api/utils/zhihu-module.js';

// Init Framework7-Vue Plugin
Framework7.use(Framework7Vue);

const app = createApp(App);

// Register Framework7 Vue Components
registerComponents(app);
try {
    await zhihuModule.initZhihu()
} catch (e) {
    console.error('Failed to initialize Zhihu module:', e);
}
window.$http = $http;
window.$zhihu = zhihuModule;

const $openLink = function (url) {
    window.open(url, '_blank', 'noopener,noreferrer')
}
window.$openLink = $openLink
app.config.globalProperties.$openLink = $openLink

const $handleCardClick = (f7router, item) => {
    const { type, id } = item;

    switch (type) {
        case "question":
            f7router.navigate(`/question/${id}`);
            break;
        case "people":
            f7router.navigate(`/user/${id}`);
            break;
        case "zvideo":
            f7router.navigate(`/video/${id}`);
            break;
        case 'column':
            f7router.navigate(`/column-items/${item.id}`);
            break;
        case "topic":
            f7router.navigate(`/topic/${id}`);
            break;
        case "collection":
            f7router.navigate(`/collection/${id}`);
            break;
        case 'roundtable':
            $openLink(`https://www.zhihu.com/roundtable/${item.id}`);
            break;
        case 'special':
            $openLink(`https://www.zhihu.com/special/${item.id}`);
            break;
        case 'browser':
            $openLink(id);
            break;
        default:
            f7router.navigate(`/article/${type}/${id}`);
            break;
    }
};

window.$handleCardClick = $handleCardClick
app.config.globalProperties.$handleCardClick = $handleCardClick

app.mount('#app');