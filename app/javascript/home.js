import './polyfill/polyfill-includes.js'
import Vue from 'vue/dist/vue.esm'
import store from './store/store.js'
import FilteredTable from './components/FilteredTable.vue'
import Modal from './components/Modal.vue'
import Vue2TouchEvents from 'vue2-touch-events'

// create event hub and export so that it can be imported into .vue files
export const eventHub = new Vue()

Vue.use(Vue2TouchEvents)

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#v-app',
    store,
    components: { FilteredTable, Modal }
  })
})
