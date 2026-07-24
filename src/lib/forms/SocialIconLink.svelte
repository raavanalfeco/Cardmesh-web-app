<script>
  import SocialIcons from '@rodneylab/svelte-social-icons';

  export let link;

  export let network;

  export let size = 22;

  export let fontColor = '';

  export let backgroundColor = '';
</script>

{#if link}
    {#if backgroundColor.length > 0 && fontColor.length > 0}
        <a href={link} target="_blank" class="social-icon-link">
            <SocialIcons alt={network} height={size} network="{network}" width={size} fgColor="{fontColor}"
                         bgColor="{backgroundColor}"/>
        </a>
    {:else}
        <a href={link} target="_blank" class="social-icon-link">
            <SocialIcons alt={network} height={size} network="{network}" width={size}/>
        </a>
    {/if}
{/if}

<style>
  .social-icon-link {
    display: inline-flex;
    border-radius: 100%;
    transition: transform 0.15s ease-out;
  }

  .social-icon-link:hover {
    transform: translateY(-2px) scale(1.08);
  }
</style>
