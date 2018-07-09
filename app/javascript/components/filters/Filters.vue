<template>
  <div>
    <span class="filter__title bold">Filters:</span>

    <data-filter v-for="filter in filters"
      :name="filter.name"
      :title="filter.title" 
      :options="filter.options"
      :type="filter.type">
    </data-filter>

    <!-- <download-csv class="inline-block"></download-csv> -->
  </div>
</template>

<script>
  import { eventHub } from "../../home.js"
  import DataFilter from './DataFilter.vue'
  import DownloadCsv from '../forms/DownloadCsv.vue'

  export default {
    name: "filters",

    components: { DataFilter, DownloadCsv },

    props: {
      filters: {
        required: true,
        type: Array
      }
    },

    data () {
      return  {
        children: this.$children
      }
    },

    mounted () {
      this.createSelectedFilterOptions()
      
      eventHub.$on('clickDropdown', this.updateDropdowns)
    },

    methods: {
      updateDropdowns (name) {
        this.children.forEach(filter => {
          filter.isOpen = filter.name == name
        })
      },

      createSelectedFilterOptions () {
        let array = []

        // create an empty array for each filter
        this.filters.forEach(filter => {
          if (filter.name !== undefined && filter.options.length > 0) {
            let obj = {}

            obj.name = filter.name
            obj.options = []
            obj.type = filter.type

            array.push(obj)
          }
        })

        console.log(array)

        this.$store.commit('setFilterOptions', array)
      },
    }
  }
</script>