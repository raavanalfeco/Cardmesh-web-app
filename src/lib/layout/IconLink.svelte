<script>
  export let ariaLabel = '';

  export let href;

  export let backgroundColor;

  export let fontColor;

  export let target = '_self';
</script>

<a
        aria-label="{ariaLabel}"
        class="btn me-2 d-flex my-auto rounded-circle p-2 border-0 icon-link"
        href="{href}"
        role="button"
        style="background-color: {backgroundColor}; color: {fontColor}"
        target="{target}"
>
    <slot/>
</a>

<style>
  .icon-link {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
    transition: transform 0.15s ease-out, box-shadow 0.15s ease-out;
  }

  .icon-link:hover {
    transform: translateY(-2px) scale(1.05);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
  }
</style>