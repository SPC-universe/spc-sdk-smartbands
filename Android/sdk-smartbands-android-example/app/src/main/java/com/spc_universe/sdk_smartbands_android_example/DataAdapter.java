package com.spc_universe.sdk_smartbands_android_example;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.List;

public class DataAdapter extends BaseAdapter {

    private List<String> list;
    private LayoutInflater inflater;

    public DataAdapter(Context context) {
        inflater = LayoutInflater.from(context);
        list = new ArrayList<>();
    }

    public LayoutInflater getInflater() {
        return inflater;
    }

    @Override
    public int getCount() {
        return list.size();
    }

    @Override
    public String getItem(int i) {
        return list.get(i);
    }

    @Override
    public long getItemId(int i) {
        return 0;
    }

    public void addText(String text){
        this.list.add(text);
        notifyDataSetChanged();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder viewHolder;
        if (convertView == null) {
            convertView = getInflater().inflate(R.layout.view_list_item, null);
            viewHolder = new ViewHolder();
            viewHolder.item = (TextView) convertView.findViewById(R.id.item);
            convertView.setTag(viewHolder);
        } else {
            viewHolder = (ViewHolder) convertView.getTag();
        }
        viewHolder.item.setText(getItem(position));
        return convertView;
    }

    private class ViewHolder {
        private TextView item;
    }
}
