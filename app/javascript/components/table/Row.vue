<template>
  <tr @click="openModal()">
    <td>{{ item.wdpa_id }}</td>
    <td>{{ item.id }}</td>
    <td>{{ checkForMultiples('iso3') }}</td>
    <td>{{ item.methodology }}</td>
    <td>{{ item.year }}</td>
    <td>{{ item.url }}</td>
    <td>{{ item.metadata_id }}</td>
  </tr>
</template>

<script>
  import { eventHub } from '../../home.js'

  export default {
    name: "row",
    props: {
      item: {
        required: true,
        type: Object,
      }
    },

    computed: {
      projectTitle () {
        return this.trim(this.item.title)
      }
    },

    methods: {
      openModal () {
        this.$store.commit('updateModalContent', this.item)

        eventHub.$emit('openModal')
      },

      checkForMultiples (field) {
        // set output to the first item in the array
        // if the array has more than 1 value then set output to 'multiple'
        let output = this.item[field][0]

        if(this.item[field].length > 1) {
          output = 'Multiple'
        } else {
          output = this.trim(output)
        }

        return output
      },

      trim (phrase) {
        const length = phrase.length
        let output

        if (length <= 30) {
          output = phrase
        } else {
          output = phrase.substring(0,27) + '...'
        }

        return output
      }
    }
  }
</script>
