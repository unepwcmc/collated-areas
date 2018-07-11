<template>
  <button 
    @click="download"
    title="Download CSV file of filtered protected area management effectiveness evaluations" 
    class="button button--download button--green"
    :class="{ 'button--disabled' : noResults }"
    v-bind="{ 'disabled' : noResults }">
    CSV
  </button>
</template>

<script>
  import axios from 'axios'

  export default {
    name: 'download-csv',

    props: {
      totalItems: {
        required: true,
        type: Number
      }
    },

    computed: {
      noResults () {
        return this.totalItems == 0
      }
    },

    methods: {
      download () {
        const csrf = document.querySelectorAll('meta[name="csrf-token"]')[0].getAttribute('content'),
          data = this.$store.state.selectedFilterOptions,
          config = {
            headers: {
              'X-CSRF-Token': csrf,
              'Accept': 'aaplication/json'
            }
          }

        axios.post('/download', data, config)
        .then(function (response) {
          console.log(response)
        })
        .catch(function (error) {
          console.log(error)
        })
      }
    }
  }
</script>