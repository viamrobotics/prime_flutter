// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	integrations: [
		starlight({
			title: 'Prime Flutter Docs',
			customCss: ['./src/styles/custom.css'],
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/viamrobotics/prime_flutter' }], // Updated href logic guess
			sidebar: [
				{
					label: 'Getting Started',
					items: [
						{ label: 'Introduction', slug: '' },
					],
				},
				{
					label: 'Components',
					autogenerate: { directory: 'components' },
				},
			],
		}),
	],
});
