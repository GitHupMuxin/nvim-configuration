" Highlight Vulkan qualifiers only inside layout(...).
syntax match glslVulkanLayoutQualifier /\%(\<layout\>\s*(\%([^)]*,\)\?\s*\)\@<=\<\%(set\|push_constant\|constant_id\)\>/
highlight default link glslVulkanLayoutQualifier glslQualifier
