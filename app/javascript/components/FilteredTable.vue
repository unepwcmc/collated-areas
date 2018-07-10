<template>
  <div class="relative">
    <filters :filters="filters"></filters>

    <table class="table table--head">
      <table-head :filters="attributes"></table-head>
    </table>

    <table class="table table--body">
      <tbody>
        <row v-for="item, key in items"
          :key="key"
          :item="item">
        </row>
      </tbody>
    </table>

    <pagination :current-page="currentPage" :items-per-page="itemsPerPage" :total-items="totalItems" :total-pages="totalPages"></pagination>
  </div>
</template>

<script>
  import axios from 'axios'
  import { eventHub } from '../home.js'
  import Filters from './filters/Filters.vue'
  import TableHead from './table/TableHead.vue'
  import Row from './table/Row.vue'
  import Pagination from './pagination/Pagination.vue'

  export default {
    name: 'filtered-table',

    components: { Filters, TableHead, Row, Pagination },

    props: {
      filters: { type: Array },
      attributes: { type: Array },
      json: { type: Object }
    },

    data () {
      return {
        currentPage: 0,
        itemsPerPage: 10,
        totalItems: 0,
        totalPages: 0,
        items: [],
        sortDirection: 1
      }
    },

    created () {
      this.updateProperties(this.json)
    },

    mounted () {
      eventHub.$on('getNewItems', this.getNewItems)
    },

    methods: {
      updateProperties (data) {
        this.currentPage = data.current_page
        this.itemsPerPage = data.per_page
        this.totalItems = data.total_entries
        this.totalPages = data.total_pages
        this.items = data.items
      },

      getNewItems () {
        //axios
        console.log(this.$store.state.requestedPage)

        let data = {
          requested_page: this.$store.state.requestedPage,
          filters: this.$store.state.selectedFilterOptions
        }

        // const instance = axios.create({
        //   baseURL: 'https://some-domain.com/api/',
        //   timeout: 1000,
        //   headers: {'X-Custom-Header': 'foobar'}
        // })

        const csrf = document.querySelectorAll('meta[name="csrf-token"]')[0].getAttribute('content')
        axios.defaults.headers.common['X-CSRF-Token'] = csrf
        axios.defaults.headers.common['Accept'] = 'application/json'

        axios.post('/list', data)
        .then(response => {
          this.updateProperties(response.data)
        })
        .catch(function (error) {
          console.log(error)
        })
      }
    }
  }
</script>
